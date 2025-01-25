//
//  HomeView.swift
//  TMT
//
//  Created by 김유빈 on 9/29/24.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding = true
    @StateObject private var apiModel: TagoApiModel
    @StateObject private var journeyModel: JourneySettingModel
    @StateObject private var imageHandler: ImageHandlerModel = ImageHandlerModel()
    @StateObject private var locationManager: LocationManager
    @StateObject private var searchModel: BusSearchModel
    
    @State private var isShowingInformation = false
    @State private var hasSeenOnboarding = false
    @State var path: [String] = []
    
    init() {
        let apiModel = TagoApiModel()
        let searchModel = BusSearchModel()
        let journeyModel = JourneySettingModel(apiManager: apiModel, searchModel: searchModel)
        
        _apiModel = StateObject(wrappedValue: apiModel)
        _searchModel = StateObject(wrappedValue: searchModel)
        _journeyModel = StateObject(wrappedValue: journeyModel)
        _locationManager = StateObject(wrappedValue: LocationManager(journeyModel: journeyModel))
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                Color.brandBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    NotUploadedView(path: $path)
                    Spacer()
                }
                .padding(.horizontal, 16)

                if isShowingInformation {
                    InformationModalView(isShowingInformation: $isShowingInformation)
                        .onDisappear {
                            hasSeenOnboarding = true
                        }
                }
            }
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
            .fullScreenCover(isPresented: $shouldShowOnboarding) {
                OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)
                    .onDisappear {
                        if !hasSeenOnboarding {
                            isShowingInformation = true
                        }
                    }
            }
        }
        .environmentObject(locationManager)
        .environmentObject(searchModel)
        .environmentObject(journeyModel)
        .environmentObject(imageHandler)
    }
}
