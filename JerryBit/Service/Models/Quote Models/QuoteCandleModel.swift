//
//  QuoteCandleModel.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

/// https://docs.upbit.com/reference#분minute-캔들-1
struct QuoteCandleModel: Decodable {
    /*
    market    마켓명    String
    candle_date_time_utc    캔들 기준 시각(UTC 기준)    String
    candle_date_time_kst    캔들 기준 시각(KST 기준)    String
    opening_price    시가    Double
    high_price    고가    Double
    low_price    저가    Double
    trade_price    종가    Double
    timestamp    해당 캔들에서 마지막 틱이 저장된 시각    Long
    candle_acc_trade_price    누적 거래 금액    Double
    candle_acc_trade_volume    누적 거래량    Double
    unit    분 단위(유닛)    Integer
     
     */
    let market: String
    let candle_date_time_utc: String
    let candle_date_time_kst: String
    let opening_price: Double
    let high_price: Double
    let low_price: Double
    let trade_price: Double
    let timestamp: Long
    let candle_acc_trade_price: Double
    let candle_acc_trade_volume: Double
    let unit: Int
}
