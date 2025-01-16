//
//  JourneyStatusHeaderView.swift
//  TMT
//
//  Created by 김유빈 on 1/12/25.
//

import SwiftUI

struct JourneyStatusHeaderView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    @State var showingAlert: Bool = false
    
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.brandBackground)
                .frame(height: 98)
                .shadow(color: .basicBlack.opacity(0.25), radius: 2.5, y: 2)
            
            HStack(alignment: .center) {
                remainingStopsInfo
                
                Spacer()
                
                stopJourneyButton
            }
            .padding(.horizontal, 35)
        }
    }
    
    private var remainingStopsInfo: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(locationManager.remainingStops)")
                .foregroundStyle(.primary)
                .font(.system(size: 40, weight: .semibold))
            
            Text("Stops Left")
                .foregroundStyle(.secondary)
                .font(.system(size: 20, weight: .bold))
        }
    }
    
    private var stopJourneyButton: some View {
        Button {
            showingAlert = true
        } label: {
            Text("End")
                .foregroundStyle(.white)
                .frame(width: 69, height: 38)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.brandPrimary)
                }
        }
        .alert("End Navigation", isPresented: $showingAlert) {
            Button("Stay", role: .cancel) { }
            
            Button("End", role: .destructive, action: action)
        } message: {
            Text("Are you sure you want to end your navigation?")
        }
    }
}

#Preview {
    let searchModel = BusSearchModel()
    let journeyModel = JourneySettingModel(searchModel: searchModel)
    let locationManager = LocationManager(journeyModel: journeyModel)
    
    journeyModel.journeyStops = BusStop.journeyStopDummy
    locationManager.remainingStops = 5
    
    return JourneyStatusHeaderView(action: {
        print("End button tapped")
    })
    .environmentObject(locationManager)
}
