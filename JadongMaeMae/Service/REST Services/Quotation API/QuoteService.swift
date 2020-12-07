//
//  QuoteService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

protocol QuoteService {
    func getMinuteCandle(market: String, unit: Int, count: Int) -> RestAPISingleResult<[QuoteCandleModel]>
}

class QuoteServiceImp: QuoteService {

    /// https://docs.upbit.com/reference#분minute-캔들-1
    func getMinuteCandle(market: String, unit: Int, count: Int) -> RestAPISingleResult<[QuoteCandleModel]> {
        let path = "/candles/minutes/\(unit)"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:])
            .set(queryName: "market", queryValue: market)
            .set(queryName: "count", queryValue: "\(count)")
            .build()
        return RestAPIClient.shared.request(request: request, type: [QuoteCandleModel].self)
    }
}
