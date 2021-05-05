//
//  QuoteCoinModel.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2021/04/02.
//

import Foundation

/// https://docs.upbit.com/reference#마켓-코드-조회
struct QuoteCoinModel: Decodable {
    
    let market: String // KRW-BTC
    let korean_name: String // 비트코인
    let english_name: String // Bitcoin
    
    private var marketCoinSeparated: [String] { market.components(separatedBy: "-") } // ["KRW", "BTC"]
    var marketKind: String {
        guard marketCoinSeparated.count == 2 else { return "" }
        return marketCoinSeparated.first ?? ""
    }
    var coinName: String {
        guard marketCoinSeparated.count == 2 else { return "" }
        return marketCoinSeparated.last ?? ""
    }
}
