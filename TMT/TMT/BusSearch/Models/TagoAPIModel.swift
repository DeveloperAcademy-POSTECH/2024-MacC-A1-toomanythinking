//
//  TagoAPIModel.swift
//  TMT
//
//  Created by Choi Minkyeong on 1/9/25.
//

import Foundation

class TagoAPIModel: NSObject, XMLParserDelegate {
    // Define the API endpoint and parameters
    private let apiKey = "pGhhz3Clzw%2FLuhS1oLNo3gX4JH%2F01HmgYdaafPhmVBGVcSNHu0hbmVRj5%2F3l%2Bf1qIz6RoMvdO2yfFIhAKa3ALg%3D%3D"
    private let baseURL = "http://apis.data.go.kr/1613000/BusRouteInfoInqireService/getRouteAcctoThrghSttnList"
    
    // Variables to hold parsed XML data
    private var currentElement: String = ""
    private var parsedData: [String: String] = [:]
    private var results: [[String: String]] = []
    
    func fetchData(cityCode: String, routeId: String, numOfRows: Int = 10, pageNo: Int = 1) {
        // URLComponents 생성 및 매개변수 추가
        guard var components = URLComponents(string: baseURL) else {
            print("Invalid base URL")
            return
        }
        
        // 기본 쿼리 매개변수 추가
        components.queryItems = [
            URLQueryItem(name: "serviceKey", value: apiKey),
            URLQueryItem(name: "cityCode", value: cityCode),
            URLQueryItem(name: "routeId", value: routeId),
            URLQueryItem(name: "numOfRows", value: "\(numOfRows)"),
            URLQueryItem(name: "pageNo", value: "\(pageNo)"),
            URLQueryItem(name: "_type", value: "xml")
        ]
        
        // URL 생성
        guard let url = components.url else {
            print("Invalid URL")
            return
        }
        
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
            
            // XML 데이터 처리
            self.parseXML(data: data)
        }
        
        task.resume()
    }
    
    // XML 데이터 파싱 (구체적인 로직은 XML 구조에 맞게 수정해야 함)
    private func parseXML(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self // XMLParserDelegate 구현 필요
        if parser.parse() {
            print("XML parsing succeeded")
        } else {
            print("XML parsing failed")
        }
    }
    
    // MARK: - XMLParserDelegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            parsedData[currentElement] = (parsedData[currentElement] ?? "") + trimmedString
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "desiredElement" { // Replace with the XML element you want to aggregate
            results.append(parsedData)
            parsedData = [:]
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parsing error: \(parseError.localizedDescription)")
    }
}

//// Usage example
//let apiManager = TransportationAPIManager()
//apiManager.fetchData(parameters: ["param1": "value1", "param2": "value2"])
