//
//  TagoAPIModel.swift
//  TMT
//
//  Created by Choi Minkyeong on 1/9/25.
//

import Foundation

class TagoAPIModel: NSObject, ObservableObject {
//    private let apiKey =
//    "pGhhz3Clzw%2FLuhS1oLNo3gX4JH%2F01HmgYdaafPhmVBGVcSNHu0hbmVRj5%2F3l%2Bf1qIz6RoMvdO2yfFIhAKa3ALg%3D%3D"

    private var currentElement = ""
    private var currentBusNumberId = ""
    private var currentStopNameKorean = ""
    private var currentStopOrder = ""
    private var currentLatitude = ""
    private var currentLongitude = ""
    
    @Published var busStopInfo: [BusStop] = []
    
    func fetchData(cityCode: String, routeId: String, numOfRows: Int = 10, pageNo: Int = 1) {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_DATA_PORTAL_API_KEY") as? String ?? ""
        
        let urlString = """
            http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteAcctoThrghSttnList?\
            serviceKey=\(apiKey)&cityCode=\(cityCode)&routeId=\(routeId)&numOfRows=\(numOfRows)&pageNo=\(pageNo)&_type=xml
            """
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        print("Generated URL: \(url)")
        
        // URLSession으로 데이터 가져오기
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "N/A")")
            self.parseXML(data: data)
        }
        
        task.resume()
    }
    
    private func parseXML(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            print("XML parsing succeeded")
        } else {
            print("XML parsing failed")
        }
    }
}

extension TagoAPIModel: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        print("started")
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        switch currentElement {
        case "routeid":
            currentBusNumberId += trimmedString
        case "nodenm":
            currentStopNameKorean += trimmedString
        case "nodeord":
            currentStopOrder += trimmedString
        case "gpslati":
            currentLatitude += trimmedString
        case "gpslong":
            currentLongitude += trimmedString
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let busStop = BusStop(
                busNumberId: currentBusNumberId,
                stopOrder: Int(currentStopOrder),
                stopNameKorean: currentStopNameKorean,
                latitude: Double(currentLatitude),
                longitude: Double(currentLongitude)
            )
            busStopInfo.append(busStop)
            print("busStopInfo: \(busStopInfo)")
            
            currentBusNumberId = ""
            currentStopNameKorean = ""
            currentStopOrder = ""
            currentLatitude = ""
            currentLongitude = ""
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Parsing finished.")
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parsing error: \(parseError.localizedDescription)")
    }
}


import SwiftUI

struct apiTest: View {
    @StateObject private var apiManager = TagoAPIModel()
    @State var isFetched: Bool = false
    
    var body: some View {
        Button {
            apiManager.fetchData(cityCode: "37010", routeId: "PHB350000365")
            isFetched = true
        } label: {
            Text("TEST")
        }
        
        if isFetched {
            Text("BusStopInfo: \(apiManager.busStopInfo)")
        }
    }
}
