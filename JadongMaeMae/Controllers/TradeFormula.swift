//
//  TradeFormula.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/11.
//

import Foundation

class TradeFormula {
    
    // 이동평균선 (20, n)
    static func movingAverageLine(period: Int = 20) -> [MovingAverage] {
        let tradePrices = TradeManager.shared.fullCandles.map { $0.trade_price }
        let skipCount = TradeManager.numberOfSkipCandleForMALine
        
        var movingAverageLine: [MovingAverage] = []
        for index in 0..<TradeManager.candleCount {
            let movingAverageValues = tradePrices[index...(index+skipCount)] // SubArray - skipCount 개의 tradePrice
            let movingAverageValue = movingAverageValues.reduce(0.0) { $0 + $1 } / Double(skipCount + 1) // SubArray 의 평균값
            movingAverageLine.append(movingAverageValue)
        }
        return movingAverageLine
    }
}
