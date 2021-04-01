//
//  MarketAll.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2021/04/02.
//

import Foundation

class MarketAll {
    static let shared = MarketAll()
    
    var coins: [QuoteCoinModel] = []
    var btcPrice: Double = 0.0
    
    func getCoin(currency: String) -> QuoteCoinModel? {
        var btcCoin: QuoteCoinModel?
        var usdtCoin: QuoteCoinModel?

        for coin in coins {
            if coin.coinName == currency {
                switch coin.marketKind {
                case "KRW": return coin
                case "BTC": btcCoin = coin
                case "USDT": usdtCoin = coin
                default: break
                }
            }
        }
        return btcCoin ?? usdtCoin ?? nil
    }
}
