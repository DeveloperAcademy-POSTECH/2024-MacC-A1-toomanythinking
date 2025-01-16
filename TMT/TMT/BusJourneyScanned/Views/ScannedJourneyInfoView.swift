//
//  ScannedJourneyInfoView.swift
//  TMT
//
//  Created by Choi Minkyeong on 11/3/24.
//

import Combine
import PhotosUI
import SwiftUI

struct ScannedJourneyInfoView: View {
    @EnvironmentObject var imageHandler: ImageHandlerModel
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var searchModel: BusSearchModel
    @EnvironmentObject var journeyModel: JourneySettingModel
    
    @State private var tag: Int? = nil
    
    @State private var showingAlert: Bool = false
    @State private var isShowingInformation = false
    @State private var isLoading = false
    
    @State private var showingPhotosPicker: Bool = false
    @State private var pickedItem: PhotosPickerItem? = nil
    
    @State private var showingLoadingAlert: Bool = false
    @State private var alertMessage = ""
    @State private var cancellable: AnyCancellable?
    
    @Binding var path: [String]
    
    var body: some View {
        ZStack {
            Color.brandBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ScrollView(showsIndicators: false) {
                    if !imageHandler.showAlertScreen {
                        UploadedPhotoView(selectedImage: $imageHandler.selectedImage)
                    } else {
                        UploadedPhotoView(selectedImage: .constant(nil))
                    }

                    uploadedInfoBox(title: "Departure Stop", scannedInfo: $imageHandler.scannedJourneyInfo.startStop)

                    uploadedInfoBox(title: "Bus Number", scannedInfo: $imageHandler.scannedJourneyInfo.busNumber)

                    uploadedInfoBox(title: "Arrival Stop", scannedInfo: $imageHandler.scannedJourneyInfo.endStop)

                }

                if imageHandler.showAlertText {
                    HStack {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Spacer()
                        }
                        Text("Opps, something seems off. Could you reupload the screenshot?")
                            .font(.system(size: 16, weight: .medium))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .onAppear {
                        imageHandler.scannedJourneyInfo = ScannedJourneyInfo(busNumber: "", startStop: "", endStop: "")
                    }
                    .frame(height: 42)
                    .foregroundStyle(.red600)
                }

                HStack(spacing: 0) {
                    Group {
                        if imageHandler.showAlertText {
                            FilledButton(title: "Reupload", fillColor: .basicBlack, textColor: .basicWhite) {
                                showingAlert = true
                            }
                        } else {
                            OutlinedButton(
                                title: "Reupload",
                                strokeColor: .brandPrimary,
                                textColor: .brandPrimary
                            ) {
                                showingAlert = true
                            }
                        }
                    }
                    .padding(.trailing, 8)
                    .alert("Information will disappear.", isPresented: $showingAlert) {
                        Button {
                            showingAlert = false
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.blue)
                        }

                        Button {
                            showingAlert = false
                            showingPhotosPicker = true
                        } label: {
                            Text("Confirm")
                                .foregroundStyle(.blue)
                                .font(.footnote.weight(.bold))
                        }
                    } message: {
                        Text("The previously uploaded image information will disappear. Do you want to proceed?")
                    }

                    PhotosPicker(selection: $pickedItem, matching: .screenshots) {
                        EmptyView()
                    }
                    .onChange(of: pickedItem) {
                        imageHandler.loadImageByPhotosPickerItem(from: pickedItem, viewCategory: "ScannedJourneyInfoView", completion: {})
                    }
                    .photosPicker(isPresented: $showingPhotosPicker, selection: $pickedItem, matching: .screenshots)

                    NavigationLink(destination: MapView(path: $path), tag: 1, selection: $tag) {
                        EmptyView()
                    }

                    FilledButton(title: "Start",
                                 fillColor: imageHandler.showAlertText ? .grey100 : .brandPrimary) {
                        isLoading = true
                        Task {
                            await NotificationManager.shared.requestNotificationPermission()
                            if !imageHandler.showAlertText {
                                journeyModel.setJourneyStops(
                                    busNumberString: imageHandler.scannedJourneyInfo.busNumber,
                                    startStopString: imageHandler.scannedJourneyInfo.startStop,
                                    endStopString: imageHandler.scannedJourneyInfo.endStop
                                )

                              guard let startStop = journeyModel.journeyStops.first else { return }
                              guard let endStop = journeyModel.journeyStops.last else { return }
                              
                              cancellable = locationManager.$remainingStops
                                    .sink { newValue in
                                        if newValue != 0 {
                                            LiveActivityManager.shared.startLiveActivity(startBusStop: startStop, endBusStop: endStop, remainingStops: locationManager.remainingStops)
                                            
                                            isLoading = false
                                            tag = 1
                                            path.append("BusStop")

                                            cancellable?.cancel()
                                        }
                                    }
                            }
                        }
                    }
                                 .onAppear {
                                     journeyModel.journeyStops = []
                                     locationManager.remainingStops = 0
                                 }
                                 .disabled(imageHandler.showAlertText)
                                 .onChange(of: isLoading) { newValue in
                                     if newValue {
                                         startLoadingTimeout()
                                     }
                                 }
                                 .alert(isPresented: $showingLoadingAlert) {
                                     Alert(
                                        title: Text("Error!"),
                                        message: Text(alertMessage),
                                        dismissButton: .default(Text("Okay")) {
                                        }
                                     )
                                 }
                }
            }
            .padding(.horizontal, 16)
            
            if isShowingInformation {
                InformationModalView(isShowingInformation: $isShowingInformation)
            }
            
            if isLoading {
                LoadingView()
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            Button {
                isShowingInformation = true
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(.grey600)
                    .font(.system(size: 17))
            }
            .disabled(isShowingInformation)
        }
    }
    
    private func uploadedInfoBox(title: String, scannedInfo: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(title)")
                .label1Medium()
                .foregroundStyle(.grey300)
            
            TextField("\(scannedInfo.wrappedValue)", text: scannedInfo)
                .font(.custom("Pretendard", size: 20).bold())
                .foregroundStyle(.textDefault)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.grey100, lineWidth: 1)
                }
                .keyboardType(title == "Bus Number" ? .numberPad : .default)
        }
    }
    
    private func startLoadingTimeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            if isLoading {
                stopLoadingWithError("Failed to load the image. Please try again.")
            }
        }
    }
    
    private func stopLoadingWithError(_ message: String) {
        isLoading = false
        alertMessage = message
        showingLoadingAlert = true
    }
}

#Preview {
    ScannedJourneyInfoView(path: .constant(["ScannedJourneyInfoView"]))
        .environmentObject(JourneySettingModel(searchModel: BusSearchModel()))
        .environmentObject(LocationManager(journeyModel: JourneySettingModel(searchModel: BusSearchModel())))
        .environmentObject(ImageHandlerModel())
        .environmentObject(JourneySettingModel(searchModel: BusSearchModel()))
        .environmentObject(LocationManager(journeyModel: JourneySettingModel(searchModel: BusSearchModel())))
}
