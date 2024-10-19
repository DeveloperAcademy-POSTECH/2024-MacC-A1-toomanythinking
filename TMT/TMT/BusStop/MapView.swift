//
//  MapView.swift
//  TMT
//
//  Created by Choi Minkyeong on 10/15/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject var busStopSearchViewModel: BusStopSearchViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: busStopSearchViewModel.filteredBusStops) { stop in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(stop.xCoordinate ?? "") ?? 0, longitude: Double(stop.yCoordinate ?? "") ?? 0)) {
                    VStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Button {
                    locationManager.findCurrentLocation()
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 40)
                            .tint(.white)
                            .shadow(radius: 5)
                        Image(systemName: "location.fill")
                            .font(.title)
                            .tint(.gray)
                    }
                }
                
            }
            .padding()
        }
        .onAppear {
            locationManager.findCurrentLocation()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    var backButton : some View {
        Button{
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.black)
                    .frame(width: 50, height: 50)
                Image(systemName: "arrow.left")
                    .foregroundStyle(.white)
            }
            
        }
    }
}
