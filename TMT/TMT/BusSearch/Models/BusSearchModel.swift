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
    
    // TODO: api 가져오는 코드 필요함.
    
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
    
    // TODO: 없어질 예정
    func loadBusStopData() {
        loadCSV(fileName: "BusStopData") { [weak self] parsedData in
            guard let self = self else { return }
            await self.applyBusStopData(parsedData)
        }
    }
    
    // TODO: api에서 제대로 된 coordinates를 제공하는지 확인해야함.
    func loadBusRouteCoordinateData() {
        loadCSV(fileName: "BusRouteCoordinates") { [weak self] parsedData in
            guard let self = self else { return }
            await self.applyBusRouteCoordinateData(parsedData)
        }
    }
    
    
    // TODO: api에 맞게 변경 필요
    @MainActor
    private func applyBusStopData(_ searchResponse: [[String]]) {
        for response in searchResponse {
            self.allBusData.append(BusStop(busNumber: response[0].isEmpty ? nil : response[0],
                                           busType: response[1].isEmpty ? nil : Int(response[1]),
                                           stopOrder: response[2].isEmpty ? nil : Int(response[2]),
                                           stopNameKorean: response[3].isEmpty ? nil : response[3],
                                           stopNameRomanized: response[4].isEmpty ? nil : response[4],
                                           stopNameNaver: response[5].isEmpty ? nil : response[5],
                                           stopNameTranslated: response[6].isEmpty ? nil : response[6],
                                           latitude: response[7].isEmpty ? nil : Double(response[7]),
                                           longitude: response[8].isEmpty ? nil : Double(response[8].dropLast(1))))
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
    
    // TODO: 얘를 api 데이터에서 검색하는걸로 바꿔야함
    // MARK: 버스 데이터 검색 (버스 번호, 정류장 이름)
    func searchBusStops(byNumber number: String) {
        filteredBusDataForNumber = allBusData.filter { busStop in
            if let busNumber = busStop.busNumber {
                return busNumber.contains(number)
            }
            return false
        }
    }
    
    func searchBusStops(byName name: String) -> [BusStop] {
        return filteredBusDataForNumber.filter {
            name.contains($0.stopNameNaver ?? "") || name.contains($0.stopNameKorean ?? "")
        }
    }
    
    /// BusRouteCoordinates csv 파일에서 해당되는 버스 번호 찾기
    func searchRouteCoordinates(byNumber number: String) {
        filteredRouteCoordinates = allRouteCoordinates.filter { route in
            return route.busNumber.contains(number)
        }
    }
}
