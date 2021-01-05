//
//  TradeFormula.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/11.
//

import Foundation

typealias MovingAverage = Double

struct BollingerBand {
    static let alpha = 2.0
    let movingAverage: MovingAverage
    let bandWidth: BandWidth
    
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
    
    static func getBollingerBands(period: Int = Trader.numberOfSkipCandleForMALine, type: MovingAverageType = .normal) -> [BollingerBand] {
        guard period > 0 else { return [] }
        let tradePrices = Trader.shared.fullCandles.map { $0.trade_price }
        
        var bollingerBands: [BollingerBand] = []
        for index in 0..<Trader.candleCount {
            let periodTradePrices = tradePrices[index...(index+(period-1))] // SubArray - skipCount 개의 tradePrice
            
            // 이동평균선
            let movingAverageValue = movingAverageLineFormula(values: Array(periodTradePrices), period: period, type: type)
            
            // 편차
            let deviations: [Double] = periodTradePrices.map { $0 - movingAverageValue }
            // 분산
            let variance = deviations.map { $0 * $0 }.reduce(0.0, +) / Double(period)
            // 표준편차
            let standardDeviation = sqrt(variance)
            // 밴드폭
            let bandWidth = BollingerBand.BandWidth(
                top: movingAverageValue + standardDeviation * BollingerBand.alpha,
                bottom: movingAverageValue - standardDeviation * BollingerBand.alpha
            )
            bollingerBands.append(BollingerBand(movingAverage: movingAverageValue, bandWidth: bandWidth))
        }
        return bollingerBands
    }
    
    static func movingAverageLineFormula(values: [MovingAverage], period: Int, type: MovingAverageType) -> MovingAverage {
        switch type {
        case .normal:
            return values.reduce(0.0) { $0 + $1 } / Double(period) // SubArray 의 평균값
        case .exponential:
            // TODO:
            return 0
        }
    }
}
