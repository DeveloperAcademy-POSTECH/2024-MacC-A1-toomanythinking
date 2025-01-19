//
//  BusSearchItem.swift
//  TMT
//
//  Created by 김유빈 on 10/15/24.
//

import Foundation

struct BusStop: Codable, Identifiable {
    var id = UUID()
    var busStopId: String? // 버스 정류장의 id
    var busNumber: String? // 노선명 (버스번호)
    var busNumberId: String? // 버스 번호의 고유 id
    var busType: Int? // 버스 타입
    var stopOrder: Int? // 순번
    var stopNameKorean: String? // 정류장명 (한글)
    var stopNameRomanized: String? // 정류장명 (로마자 표기)
    var stopNameNaver: String? // 정류장명 (네이버맵에서 제공하는 의미 번역)
    var stopNameTranslated: String? // 정류장명 (직접 번역한 이름)
    var latitude: Double? // x좌표
    var longitude: Double? // y좌표
    var cityCode: String? // 도시 코드
    var cityName: String? // 도시 이름
    var routeDetail: String? // 버스 루트에 대한 상세 정보 (ex. 자명 경유 등)
}
