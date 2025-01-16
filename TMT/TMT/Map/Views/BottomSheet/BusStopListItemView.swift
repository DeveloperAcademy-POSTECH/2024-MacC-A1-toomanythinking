//
//  BusStopListItemView.swift
//  TMT
//
//  Created by 김유빈 on 1/12/25.
//

import SwiftUI

struct BusStopListItemView: View {
    let stop: BusStop
    let isPartOfJourney: Bool
    //    let isCurrentStop: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            journeyIndicator
            
            VStack(alignment: .leading, spacing: 0) {
                busStopNamesView
                
                Divider()
                    .background(.busStopLine)
            }
            .background(isPartOfJourney ? .brandBackground  : .busStopUnselect)
        }
    }
    
    private var journeyIndicator: some View {
        // TODO: 선 양 끝에 둥근 처리하기
        Rectangle()
            .frame(width: 8)
            .overlay {
                Image(isPartOfJourney ? "ActiveDot" : "UnactiveDot")
                    .resizable()
                    .frame(width: 8, height: 8)
            }
            .foregroundStyle(isPartOfJourney ? .brandPrimary : .grey100)
            .padding(.leading, 57)
            .padding(.trailing, 28)
            .background(.backgroundModal)
    }
    
    private var busStopNamesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(stop.stopNameKorean ?? "")
                .body2Regular()
                .foregroundStyle(isPartOfJourney ? .textDefault : .grey400)
            
            Text("[\(stop.stopNameRomanized ?? "")]")
                .label3Regular()
                .foregroundStyle(.grey400)
            
            if isPartOfJourney {
                Text(stop.stopNameTranslated ?? "")
                    .body2Regular()
                    .foregroundStyle(.textDefault)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(10)
    }
}

#Preview {
    let sampleBusStop = BusStop.busStopDummy[1]
    
    BusStopListItemView(stop: sampleBusStop, isPartOfJourney: true)
}
