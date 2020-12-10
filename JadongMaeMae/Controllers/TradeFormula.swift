//
//  TradeFormula.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/11.
//

import Foundation

typealias MovingAverage = Double

struct BollingerBand {
    let movingAverage: MovingAverage
    let stateValue: Float
    
    struct BandWidth {
        let top: Double
        let bottom: Double
    }
}

class TradeFormula {
    
    enum MovingAverageType {
        // 이동평균선 (20, n)
        case normal
        // 지수 이동평균선 (20, n), EMA
        case exponential
    }
    
    static func movingAverageLine(period: Int = 20, type: MovingAverageType = .normal) -> [MovingAverage] {
        let tradePrices = TradeManager.shared.fullCandles.map { $0.trade_price }
        let skipCount = TradeManager.numberOfSkipCandleForMALine
        
        var movingAverageLine: [MovingAverage] = []
        for index in 0..<TradeManager.candleCount {
            let movingAverageValues = tradePrices[index...(index+skipCount)] // SubArray - skipCount 개의 tradePrice
            let movingAverageValue = movingAverageLineFormula(values: Array(movingAverageValues), type: type)
            movingAverageLine.append(movingAverageValue)
        }
        return movingAverageLine
    }
    
    static func movingAverageLineFormula(values: [MovingAverage], type: MovingAverageType) -> MovingAverage {
        let skipCount = TradeManager.numberOfSkipCandleForMALine
        switch type {
        case .normal:
            return values.reduce(0.0) { $0 + $1 } / Double(skipCount + 1) // SubArray 의 평균값
        case .exponential:
            // TODO:
            return 0
        }
    }
}
