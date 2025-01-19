//
//  BusSearchModel.swift
//  TMT
//
//  Created by 김유빈 on 10/15/24.
//

import Foundation

final class BusSearchModel: ObservableObject {
    @Published var allStopData: [BusStop] = []
    @Published var allBusNumberData: [BusStop] = []
    @Published var filteredBusDataForNumber: [BusStop] = []
    @Published var filteredRouteCoordinates: [Coordinate] = []
    
    var allRouteCoordinates: [Coordinate] = []
    
    init() {
        loadBusStopData()
        loadBusNumberData()
        loadBusRouteCoordinateData()
    }
    
    private func loadCSV(fileName: String, completion: @escaping ([[String]]) async -> Void) {
        Task {
            guard let filepath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
                print("Error \(#function) in \(#file) :: \(fileName).csv file not found")
                return
            }
            do {
                let content = try String(contentsOfFile: filepath)
                
                let response = content.components(separatedBy: "\n")
                let parsedData = response.map { $0.components(separatedBy: ",") }
                
                await completion(parsedData)
            } catch {
                print("Error \(#function) in \(#file) :: Unable to read \(fileName).csv")
            }
        }
    }
    
    func loadBusStopData() {
        loadCSV(fileName: "BusStopData") { [weak self] parsedData in
            guard let self = self else { return }
            await self.applyBusStopData(parsedData)
        }
    }
    
    func loadBusNumberData() {
        loadCSV(fileName: "BusNumbers") { [weak self] parsedData in
            guard let self = self else { return }
            await self.applyBusNumberData(parsedData)
        }
    }
    
    func loadBusRouteCoordinateData() {
        loadCSV(fileName: "BusRouteCoordinates") { [weak self] parsedData in
            guard let self = self else { return }
            await self.applyBusRouteCoordinateData(parsedData)
        }
    }
    
    @MainActor
    private func applyBusStopData(_ searchResponse: [[String]]) {
        for response in searchResponse {
            self.allStopData.append(BusStop(busStopId: response[0].isEmpty ? nil : response[0],
                                            stopNameKorean: response[1].isEmpty ? nil: response[1],
                                            stopNameRomanized: response[2].isEmpty ? nil : response[2],
                                            stopNameNaver: response[4].isEmpty ? nil : response[4],
                                            stopNameTranslated: response[3].isEmpty ? nil : response[3]))
        }
    }
    
    @MainActor
    private func applyBusNumberData(_ searchResponse: [[String]]) {
        for response in searchResponse {
            self.allBusNumberData.append(BusStop(
                busNumber: response[0].isEmpty ? nil : response[0],
                busNumberId: response[1].isEmpty ? nil : response[1],
                cityCode: response[2].isEmpty ? nil : response[2],
                cityName: response[3].isEmpty ? nil : response[3],
                routeDetail: response[4].isEmpty ? nil : response[4]))
        }
    }
    
    @MainActor
    private func applyBusRouteCoordinateData(_ searchResponse: [[String]]) {
        for response in searchResponse {
            self.allRouteCoordinates.append(Coordinate(busNumber: response[0],
                                                       stopNameKorean: response[1],
                                                       stopOrder: Int(response[2]) ?? 0,
                                                       latitude: Double(response[3]) ?? 0,
                                                       longitude: Double(response[4].dropLast(1)) ?? 0))
        }
    }
    
    // MARK: 버스 데이터 검색 (버스 번호)
    func searchBusStops(byNumber number: String) {
        filteredBusDataForNumber = allBusNumberData.filter { busStop in
            if let busNumber = busStop.busNumber {
                return busNumber.contains(number)
            }
            return false
        }
    }
    
    /// BusRouteCoordinates csv 파일에서 해당되는 버스 번호 찾기
    func searchRouteCoordinates(byNumber number: String) {
        filteredRouteCoordinates = allRouteCoordinates.filter { route in
            return route.busNumber.contains(number)
        }
    }
}
