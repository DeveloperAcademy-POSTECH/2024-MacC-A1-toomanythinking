//
//  TMTWidgetLiveActivity.swift
//  TMTWidget
//
//  Created by 김유빈 on 10/17/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BusJourneyAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var remainingStopsCount: Int
        
        var thisStopNameKorean: String
        var thisStopNameRomanized: String
    }
    
    // Fixed non-changing properties about your activity go here!
}

struct BusJourneyLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BusJourneyAttributes.self) { context in
            // Lock screen/banner UI goes here
            // MARK: Lock Screen
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                        
                        Text("This Stop")
                            .label1Medium()
                    }
                    .padding(.bottom, 4)
                    
                    Text(context.state.thisStopNameKorean)
                        .title4()

                    Text("[\(context.state.thisStopNameRomanized)]") // TODO: 여러 줄로 보이도록 하기
                        .label1Medium()
                }
                .foregroundStyle(.textDefault)
                .multilineTextAlignment(.leading)

                Spacer()
                
                Image("TrailingBig")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                    .frame(width: 80, height: 80)
                    .overlay {
                        VStack(spacing: -4) {
                            Text("\(context.state.remainingStopsCount)")
                                .title2()
                                .foregroundStyle(.textLeft)

                            Text("Stops Left")
                                .label1Medium()
                                .foregroundStyle(.textLeft)
                        }
                    }
            }
            .padding(16)
            
        } dynamicIsland: { context in
            // MARK: Expanded
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "location.fill") // TODO: 도착지 - 핀 / 현재 정류장 - location
                            .renderingMode(.template)
                            .frame(width: 12)
                        
                        Text("This Stop")
                            .label1Medium()
                            .padding(.bottom, 4)
                    }
                    .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                    .padding([.leading, .top], 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 9) {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(context.state.thisStopNameKorean)
                                    .title4()
                                    .foregroundStyle(.grey50)

                                Text("[\(context.state.thisStopNameRomanized)]")
                                    .label1Medium()
                                    .foregroundStyle(.grey50)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .center, spacing: 6) {
                            Spacer()
                            
                            // MARK: 남은 정류장 수
                            HStack(alignment: .bottom, spacing: 2) {
                                Text("\(context.state.remainingStopsCount)")
                                    .title2()

                                Text("Stops Left")
                                .label1Medium()
                            }
                            .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7.5)
                            .background {
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundStyle(.grey900)
                                
                            }
                            
                            // TODO: this stop 버튼
                            //
                            //                            Button {
                            //                            } label: {
                            //                                RoundedRectangle(cornerRadius: 25)
                            //                                    .frame(width: 44, height: 44)
                            //                                    .overlay {
                            //                                        Image(systemName: "location.fill")
                            //                                            .frame(width: 16, height: 16)
                            //                                            .foregroundStyle(.basicBlack)
                            //                                    }
                            //                                    .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                            //
                            //                            }
                            //                            .buttonStyle(.plain)
                            //
                            // TODO: destination 버튼
                            //                            Button {
                            //                            } label: {
                            //                                RoundedRectangle(cornerRadius: 25)
                            //                                    .frame(width: 44, height: 44)
                            //                                    .overlay {
                            //                                        Image("Pin")
                            //                                            .resizable()
                            //                                            .frame(width: 16, height: 16)
                            //                                            .foregroundStyle(.basicBlack)
                            //                                    }
                            //                                    .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                            //                            }
                            //                            .buttonStyle(.plain)
                        }
                    }
                    .padding([.trailing, .bottom], 8)
                }
            } compactLeading: { // MARK: Compact Leading
                Image("LeadingLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 17)
                    .padding(.horizontal, 9)

            } compactTrailing: { // MARK: Compact Trailing
                Image("TrailingSmall")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                    .frame(width: 21, height: 22)
                    .overlay {
                        Text("\(context.state.remainingStopsCount)")
                            .label1Medium()
                            .foregroundStyle(.basicBlack)
                    }

            } minimal: { // MARK: Minimal
                Image("TrailingSmall")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(StopStatusEnum(remainingStops: context.state.remainingStopsCount).statusColor)
                    .frame(width: 21, height: 22)
                    .overlay {
                        Text("\(context.state.remainingStopsCount)")
                            .label1Medium()
                            .foregroundStyle(.basicBlack)
                    }
            }
            .keylineTint(.brandPrimary)
        }
    }
}


// MARK: - Preview
extension BusJourneyAttributes {
    fileprivate static var preview: BusJourneyAttributes {
        BusJourneyAttributes()
    }
}

extension BusJourneyAttributes.ContentState {
    fileprivate static var Postech55: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(remainingStopsCount: 55, thisStopNameKorean: "포스텍", thisStopNameRomanized: "Postech")
    }
    
    fileprivate static var HyoGokDong3: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(remainingStopsCount: 3, thisStopNameKorean: "효곡동행정복지센터", thisStopNameRomanized: "Hyo-gok-dong Haeng-jeong Bok-ji Center")
    }
    
    fileprivate static var HyoGokDong2: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(remainingStopsCount: 2, thisStopNameKorean: "효곡동행정복지센터", thisStopNameRomanized: "Hyo-gok-dong Haeng-jeong Bok-ji Center")
    }
    
    fileprivate static var HyoGokDong1: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(remainingStopsCount: 1, thisStopNameKorean: "효곡동행정복지센터", thisStopNameRomanized: "Hyo-gok-dong Haeng-jeong Bok-ji Center")
    }
    
    fileprivate static var HyoGokDong0: BusJourneyAttributes.ContentState {
        BusJourneyAttributes.ContentState(remainingStopsCount: 0, thisStopNameKorean: "효곡동행정복지센터", thisStopNameRomanized: "Hyo-gok-dong Haeng-jeong Bok-ji Center")
    }
}

#Preview("Lock Screen", as: .content, using: BusJourneyAttributes.preview) {
    BusJourneyLiveActivity()
} contentStates: {
    BusJourneyAttributes.ContentState.Postech55
    BusJourneyAttributes.ContentState.HyoGokDong3
    BusJourneyAttributes.ContentState.HyoGokDong2
    BusJourneyAttributes.ContentState.HyoGokDong1
    BusJourneyAttributes.ContentState.HyoGokDong0
}

#Preview("Expanded Dynamic Island", as: .dynamicIsland(.expanded), using: BusJourneyAttributes.preview) {
    BusJourneyLiveActivity()
} contentStates: {
    BusJourneyAttributes.ContentState.Postech55
    BusJourneyAttributes.ContentState.HyoGokDong3
    BusJourneyAttributes.ContentState.HyoGokDong2
    BusJourneyAttributes.ContentState.HyoGokDong1
    BusJourneyAttributes.ContentState.HyoGokDong0
}

#Preview("Compact Dynamic Island", as: .dynamicIsland(.compact), using: BusJourneyAttributes.preview) {
    BusJourneyLiveActivity()
} contentStates: {
    BusJourneyAttributes.ContentState.Postech55
    BusJourneyAttributes.ContentState.HyoGokDong3
    BusJourneyAttributes.ContentState.HyoGokDong2
    BusJourneyAttributes.ContentState.HyoGokDong1
    BusJourneyAttributes.ContentState.HyoGokDong0
}

#Preview("Minimal Dynamic Island", as: .dynamicIsland(.minimal), using: BusJourneyAttributes.preview) {
    BusJourneyLiveActivity()
} contentStates: {
    BusJourneyAttributes.ContentState.Postech55
    BusJourneyAttributes.ContentState.HyoGokDong3
    BusJourneyAttributes.ContentState.HyoGokDong2
    BusJourneyAttributes.ContentState.HyoGokDong1
    BusJourneyAttributes.ContentState.HyoGokDong0
}
