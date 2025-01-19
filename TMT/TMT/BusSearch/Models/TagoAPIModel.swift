//
//  TagoAPIModel.swift
//  TMT
//
//  Created by Choi Minkyeong on 1/9/25.
//

import Foundation

class TagoApiModel: NSObject, ObservableObject {
    @Published var busStopApiInfo: [BusStop] = []
    
    private var currentElement = ""
    private var currentBusNumberId = ""
    private var currentBusStopId = ""
    private var currentStopNameKorean = ""
    private var currentStopOrder = ""
    private var currentLatitude = ""
    private var currentLongitude = ""
    
    func fetchData(cityCode: String, routeId: String, numOfRows: Int = 500, pageNo: Int = 1) async {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "PUBLIC_DATA_PORTAL_API_KEY") as? String ?? ""
        let urlString = """
            http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteAcctoThrghSttnList?\
            serviceKey=\(apiKey)&cityCode=\(cityCode)&routeId=\(routeId)&numOfRows=\(numOfRows)&pageNo=\(pageNo)&_type=xml
            """
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.parseXML(data: data)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
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

extension TagoApiModel: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedString.isEmpty else { return }
        
        switch currentElement {
        case "routeid":
            currentBusNumberId += trimmedString
        case "nodeid":
            currentBusStopId += trimmedString
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
                busStopId: currentBusStopId,
                busNumberId: currentBusNumberId,
                stopOrder: Int(currentStopOrder),
                stopNameKorean: currentStopNameKorean,
                latitude: Double(currentLatitude),
                longitude: Double(currentLongitude)
            )
            
            self.busStopApiInfo.append(busStop)
            
            currentBusStopId = ""
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
