//
//  QuoteService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

protocol QuoteService {
    func getMarketAllCoins() -> RestAPISingleResult<[QuoteCoinModel]>
    func getMinuteCandle(market: String, unit: Int, count: Int) -> RestAPISingleResult<[QuoteCandleModel]>
    func getCurrentPrice(markets: [String]) -> RestAPISingleResult<[QuoteTickerModel]>
}

class QuoteServiceImp: QuoteService {

    /// https://docs.upbit.com/reference#마켓-코드-조회
    func getMarketAllCoins() -> RestAPISingleResult<[QuoteCoinModel]> {
        let path = "/v1/market/all"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:])
            .build()
        return RestAPIClient.shared.request(request: request, type: [QuoteCoinModel].self)
    }
    
    /// https://docs.upbit.com/reference#분minute-캔들-1
    func getMinuteCandle(market: String, unit: Int, count: Int) -> RestAPISingleResult<[QuoteCandleModel]> {
        let path = "/v1/candles/minutes/\(unit)"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:])
            .set(queryName: "market", queryValue: market)
            .set(queryName: "count", queryValue: "\(count)")
            .build()
        return RestAPIClient.shared.request(request: request, type: [QuoteCandleModel].self)
    }
    
    /// https://docs.upbit.com/reference#ticker현재가-내역
    func getCurrentPrice(markets: [String]) -> RestAPISingleResult<[QuoteTickerModel]> {
        let path = "/v1/ticker"
        let marketsQuery = markets.joined(separator: ",")
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:])
            .set(queryName: "markets", queryValue: marketsQuery)
            .build()
        return RestAPIClient.shared.request(request: request, type: [QuoteTickerModel].self)
    }
}
