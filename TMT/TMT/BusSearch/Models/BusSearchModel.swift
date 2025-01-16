//
//  BusSearchModel.swift
//  TMT
//
//  Created by 김유빈 on 10/15/24.
//

import Foundation

final class BusSearchModel: ObservableObject {
    @Published var allBusData: [BusStop] = []
    @Published var filteredBusDataForNumber: [BusStop] = []
    @Published var filteredRouteCoordinates: [Coordinate] = []
    
    var allRouteCoordinates: [Coordinate] = []
    
    init() {
        loadBusStopData()
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
        loadCSV(fileName: "test") { [weak self] parsedData in
            guard let self = self else { return }
            await self.applyBusStopData(parsedData)
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
            self.allBusData.append(BusStop(busStopId: response[0].isEmpty ? nil : response[0],
                                           busNumber: response[1].isEmpty ? nil : response[1],
                                           busNumberId: response[2].isEmpty ? nil : response[2],
                                           busType: response[3].isEmpty ? nil : Int(response[3]),
                                           stopNameRomanized: response[4].isEmpty ? nil : response[4],
                                           stopNameNaver: response[5].isEmpty ? nil : response[5],
                                           stopNameTranslated: response[6].isEmpty ? nil : response[6]))
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
        filteredBusDataForNumber = allBusData.filter { busStop in
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
