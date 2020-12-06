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
 ]
 */

struct AccountModel: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case currency
    }

    let currency: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.init(currency: currency)
    }
    init(currency: String?) {
        self.currency = currency
    }
}
