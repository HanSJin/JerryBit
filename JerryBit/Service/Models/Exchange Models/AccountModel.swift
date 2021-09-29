//
//  AccountModel.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

/*
 https://docs.upbit.com/reference#자산-조회
 
 [
    {
     "currency":"KRW",
     "balance":"1000000.0",
     "locked":"0.0",
     "avg_buy_price":"0",
     "avg_buy_price_modified":false,
     "unit_currency": "KRW",
    },
    ...
 
     필드    설명    타입
     currency    화폐를 의미하는 영문 대문자 코드    String
     balance    주문가능 금액/수량    NumberString
     locked    주문 중 묶여있는 금액/수량    NumberString
     avg_buy_price    매수평균가    NumberString
     avg_buy_price_modified    매수평균가 수정 여부    Boolean
     unit_currency    평단가 기준 화폐    String
 
 ]
 */

class AccountModel: Decodable {
    let currency: String
    let balance: String
    let locked: String
    let avg_buy_price: String
    var avg_buy_price_modified: Bool
    let unit_currency: String

    // MARK: - Converted
    var balanceDouble: Double { Double(balance) ?? 0.0 }
    var lockedDouble: Double { Double(locked) ?? 0.0 }
    var avgBuyPriceDouble: Double { Double(avg_buy_price) ?? 0.0 }
    var unitCurrencyString: String { unit_currency }
    var quoteTickerModel: QuoteTickerModel?
    
    var tradePrice: Double {
        let price = quoteTickerModel?.trade_price ?? 0
        if coinMarketInfo?.marketKind == "BTC" {
            return price * MarketAll.shared.btcPrice
        }
        return price
    }
    var currentTotalPrice: Double {
        return tradePrice * (balanceDouble + lockedDouble)
    }
    
    // MARK: - Coin Detail
    var coinMarketInfo: QuoteCoinModel?
    var fullCurrencyName: String {
        guard let coinMarketInfo = coinMarketInfo, !coinMarketInfo.marketKind.isEmpty else { return "" }
        return coinMarketInfo.marketKind + "-" + currency
    }
}
