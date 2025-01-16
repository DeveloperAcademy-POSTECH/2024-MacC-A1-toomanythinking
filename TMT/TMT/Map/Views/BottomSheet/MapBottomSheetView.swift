//
//  MapBottomSheetView.swift
//  TMT
//
//  Created by 김유빈 on 11/18/24.
//

import SwiftUI

struct MapBottomSheetView: View {
    @EnvironmentObject var searchModel: BusSearchModel
    @EnvironmentObject var journeyModel: JourneySettingModel
    
    @Binding var path: [String]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    stopsListSection(proxy: proxy)
                }
            }
            .overlay(alignment: .top) {
                JourneyStatusHeaderView(action: endButtonAction)
            }
        }
    }
    
    private func stopsListSection(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Section {
                Rectangle()
                    .frame(height: 100)
                    .foregroundStyle(.background)
            }
            
            // TODO: 현재 정류장 표시
            ForEach(searchModel.filteredBusDataForNumber) { stop in
                let isPartOfJourney = journeyModel.journeyStops.contains { $0.stopOrder == stop.stopOrder }
                
                BusStopListItemView(stop: stop, isPartOfJourney: isPartOfJourney)
                    .id(stop.stopOrder)
            }
        }
        .onAppear {
            proxy.scrollTo(journeyModel.journeyStops.first!.stopOrder)
        }
        .onChange(of: journeyModel.lastPassedStopIndex) {
            proxy.scrollTo(journeyModel.journeyStops[journeyModel.lastPassedStopIndex].stopOrder)
        }
    }
    
    private func endButtonAction() {
        if journeyModel.journeyStops.last != nil {
            LiveActivityManager.shared.endLiveActivity()
        }
        
        path.removeAll()
    }
}

#Preview {
    let searchModel = BusSearchModel()
    let journeyModel = JourneySettingModel(searchModel: searchModel)
    let locationManager = LocationManager(journeyModel: journeyModel)
    
    searchModel.filteredBusDataForNumber = BusStop.journeyStopDummy
    journeyModel.journeyStops = BusStop.journeyStopDummy
    
    return MapBottomSheetView(path: .constant([]))
        .environmentObject(searchModel)
        .environmentObject(journeyModel)
        .environmentObject(locationManager)
}
