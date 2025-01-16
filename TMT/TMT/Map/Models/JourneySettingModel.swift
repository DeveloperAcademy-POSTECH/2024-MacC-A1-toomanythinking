//
//  JourneySettingModel.swift
//  TMT
//
//  Created by 김유빈 on 11/11/24.
//

import Foundation
import MapKit

final class JourneySettingModel: ObservableObject {
    @Published var busStopInfo: [BusStop] = []
    @Published var journeyStops: [BusStop] = []
    
    private let apiManager: TagoApiModel
    private let searchModel: BusSearchModel
    
    private var startStop: BusStop?
    private var endStop: BusStop?
    private var busNumberId: String = ""
    
    @Published var closestStop: BusStop?
    @Published var lastPassedStopIndex: Int = -1
    
    init(apiManager: TagoApiModel, searchModel: BusSearchModel) {
        self.apiManager = apiManager
        self.searchModel = searchModel
    }
    
    // MARK: 출발 및 하차 정류장 설정
    func setJourneyStops(busNumberString: String, startStopString: String, endStopString: String) {
        searchModel.searchBusStops(byNumber: busNumberString)
        busNumberId = searchModel.filteredBusDataForNumber.first?.busNumberId ?? ""
        
        Task {
            await apiManager.fetchData(cityCode: "37010", routeId: busNumberId)
            busStopInfo = mergeBusStops(busInfoCsv: searchModel.filteredBusDataForNumber, busInfoApi: apiManager.busStopApiInfo)
            
            let startCandidates = searchBusStops(byName: startStopString)
            let endCandidates = searchBusStops(byName: endStopString)
            
            findJourneyStopsSequence(from: startCandidates, to: endCandidates)
            print("journeyStops: \(journeyStops)")
        }
    }
    
    private func searchBusStops(byName name: String) -> [BusStop] {
        return busStopInfo.filter {
            name.contains($0.stopNameNaver ?? "") || name.contains($0.stopNameKorean ?? "")
        }
    }
    
    // MARK: 출발 정류장부터 하차 정류장까지 배열 찾기
    private func findJourneyStopsSequence(from startCandidates: [BusStop], to endCandidates: [BusStop]) {
        if let validStops = findValidStartAndEndStops(from: startCandidates, to: endCandidates) {
            self.startStop = validStops.startStop
            self.endStop = validStops.endStop
            
            if let startOrder = validStops.startStop.stopOrder, let endOrder = validStops.endStop.stopOrder {
                let filteredStops = busStopInfo.filter {
                    guard let order = $0.stopOrder else { return false }
                    return $0.busNumber == startStop?.busNumber && order >= startOrder && order <= endOrder
                }
                self.journeyStops = filteredStops
            }
        }
    }
    
    private func findValidStartAndEndStops(from startCandidates: [BusStop], to endCandidates: [BusStop]) -> (startStop: BusStop, endStop: BusStop)? {
        let startOrders = startCandidates.compactMap { $0.stopOrder }
        let endOrders = endCandidates.compactMap { $0.stopOrder }
        guard let startMin = startOrders.min(), let endMin = endOrders.min(),
              let startMax = startOrders.max(), let endMax = endOrders.max() else { return nil }
        
        if startMin < endMin {
            if let startInfo = startCandidates.first(where: { $0.stopOrder == startMin }),
               let endInfo = endCandidates.first(where: { $0.stopOrder == endMin }) {
                return (startInfo, endInfo)
            }
        } else {
            if let startInfo = startCandidates.first(where: { $0.stopOrder == startMax }),
               let endInfo = endCandidates.first(where: { $0.stopOrder == endMax }) {
                return (startInfo, endInfo)
            }
        }
        return nil
    }
    
    /// 실시간으로 남은 정류장 수 업데이트
    func updateRemainingStopsAndCurrentStop(currentLocation: CLLocationCoordinate2D) -> (remainingStops: Int, currentStop: BusStop?) {
        guard !journeyStops.isEmpty else {
            print("정류장 설정 plz ..")
            return (0, self.startStop)
        }
        
        var currentStop = journeyStops.first
        let userLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        for (index, stop) in journeyStops.enumerated() {
            guard index > lastPassedStopIndex,
                  let stopLatitude = stop.latitude,
                  let stopLongitude = stop.longitude else { continue }
            
            let stopLocation = CLLocation(latitude: stopLatitude, longitude: stopLongitude)
            
            if userLocation.distance(from: stopLocation) < 50.0 {
                lastPassedStopIndex = index
                currentStop = stop
                break
            }
        }
        
        let remainingStops = max(0, journeyStops.count - lastPassedStopIndex - 1)
        return (remainingStops, currentStop)
    }
    
    private func mergeBusStops(busInfoCsv: [BusStop], busInfoApi: [BusStop]) -> [BusStop] {
        let apiArrayToDict = Dictionary(grouping: busInfoApi, by: { $0.busStopId ?? "" })
        var mergedBusStops: [BusStop] = []
        print("================apiDict==================")
        print("apiDict: \(apiArrayToDict)")
        
        for stopInCsv in busInfoCsv {
            guard let busStopId = stopInCsv.busStopId else { continue }
            print("busStopId: \(busStopId)")
            if let matchingApiStops = apiArrayToDict[busStopId] {
                for stopInApi in matchingApiStops {
                    var mergedStop = stopInCsv
                    mergedStop.stopOrder = stopInApi.stopOrder
                    mergedStop.stopNameKorean = stopInApi.stopNameKorean
                    mergedStop.latitude = stopInApi.latitude
                    mergedStop.longitude = stopInApi.longitude
                    
                    mergedBusStops.append(mergedStop)
                }
            } else {
                mergedBusStops.append(stopInCsv)
            }
        }
        
        return mergedBusStops
    }
}
