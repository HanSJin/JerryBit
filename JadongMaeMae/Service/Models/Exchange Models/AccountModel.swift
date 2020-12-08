//
//  AccountModel.swift
//  JadongMaeMae
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
    let currency: String?
    private let balance: String?
    private let locked: String?
    private let avg_buy_price: String?
    var avg_buy_price_modified: Bool
    let unit_currency: String?

    // MARK: - Converted
    var balanceDouble: Double { Double(balance ?? "0.0") ?? 0.0 }
    var lockedDouble: Double { Double(locked ?? "0.0") ?? 0.0 }
    var avgBuyPriceDouble: Double { Double(avg_buy_price ?? "0.0") ?? 0.0 }
    var unitCurrencyString: String { unit_currency ?? "" }
    var quoteTickerModel: QuoteTickerModel?
    
    var tradePrice: Double { quoteTickerModel?.trade_price ?? 0 }
    var currentTotalPrice: Double {
        return tradePrice * (balanceDouble + lockedDouble)
    }
//    private enum CodingKeys: String, CodingKey {
//        case currency
//    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let currency = try container.decodeIfPresent(String.self, forKey: .currency)
//        self.init(currency: currency)
//    }
//    init(currency: String?) {
//        self.currency = currency
//    }
}
