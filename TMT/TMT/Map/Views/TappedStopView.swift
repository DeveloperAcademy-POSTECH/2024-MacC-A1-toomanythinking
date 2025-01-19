//
//  TappedStopView.swift
//  TMT
//
//  Created by Choi Minkyeong on 11/25/24.
//

import SwiftUI

struct TappedStopView: View {
    @EnvironmentObject var journeyModel: JourneySettingModel
    @EnvironmentObject var selectedStopManager: SelectedStopManager
    
    @State private var stopOrder: Int? = 0
    
    @Binding var tappedStop: BusStop
    @Binding var tappedViewSize: CGSize
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                BusStopDetailView(isEndStopViewVisible: false, stopNameKorean: tappedStop.stopNameKorean ?? "", stopNameRomanized: tappedStop.stopNameRomanized ?? "", stopNameTranslated: tappedStop.stopNameTranslated ?? "")
                    .padding(.horizontal, 16)
                    .padding(.top, 25)
                    .padding(.bottom, 14)
                    .background {
                        PopoverView()
                            .fill(.toolTipBackground.opacity(0.8))
                    }
                    .frame(width: 280)
                    .onAppear {
                        tappedViewSize = geometry.size
                    }
            }
            .frame(width: 280)
        }
        .onAppear {
            updateStateOrder()
            if let stopOrder = stopOrder {
                tappedStop = journeyModel.busStopInfo[stopOrder]
            } else {
                print("Error is occured. Please try again.")
            }
        }
        .onChange(of: selectedStopManager.selectedIndex) {
            updateStateOrder()
        }
    }
    
    private func updateStateOrder() {
        stopOrder = selectedStopManager.selectedIndex
    }
}
