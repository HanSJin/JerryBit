//
//  TradeMachineViewController+Chart.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/20.
//

import UIKit

// MARK: - ChartViewDelegate
extension TradeMachineViewController: ChartViewDelegate {
    
    func setUpChart() {
        chartView.delegate = self
        chartView.chartDescription.enabled = false
        chartView.backgroundColor = .idChartColor
        
        chartView.drawBarShadowEnabled = false
        chartView.highlightFullBarEnabled = false
        
        chartView.drawOrder = [
            DrawOrder.candle.rawValue,
            DrawOrder.line.rawValue,
        ]
        chartView.maxVisibleCount = Trader.candleCount
        chartView.dragXEnabled = true
        chartView.dragYEnabled = false
//        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
//        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawBordersEnabled = false
        chartView.dragEnabled = true
        chartView.highlightPerTapEnabled = true
        
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        
        chartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 9)
        chartView.rightAxis.labelTextColor = UIColor.white.withAlphaComponent(0.8)
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        chartView.xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    func updateChartData() {
        // Start -> End 까지 0.002 ms 경과 (Line+Candle)
        // print("start", Date().toStringWithDefaultFormat())
        chartView.data = nil
        setDataCount()
        // print("end", Date().toStringWithDefaultFormat())
    }
    
    private func setDataCount() {
        let data = CombinedChartData()
        data.lineData = generateLineData()
        data.candleData = generateCandleData()
        chartView.xAxis.axisMaximum = data.xMax + 0.25
        chartView.data = data
    }
    
    private func generateLineData() -> LineChartData {
        // 20,2 이동평균선
        let movingAverageLine = Trader.shared.bollingerBands.map { $0.movingAverage.rounded }
        let entries = movingAverageLine.reversed().enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(UIColor.white)
        set.lineWidth = 0.8
        set.setCircleColor(.clear)
        set.circleRadius = 0
        set.circleHoleRadius = 0
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueTextColor = .white
        set.highlightColor = .clear
        set.axisDependency = .right
        
        // 볼린저밴드 상단
        let topBandWidths = Trader.shared.bollingerBands.map { $0.bandWidth.top.rounded }
        let topEntries = topBandWidths.reversed().enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let topSet = LineChartDataSet(entries: topEntries, label: "Filled Line DataSet Top")
        topSet.setColor(UIColor.white)
        topSet.lineWidth = 1.3
        topSet.setCircleColor(.clear)
        topSet.circleRadius = 0
        topSet.circleHoleRadius = 0
        topSet.mode = .cubicBezier
        topSet.axisDependency = .right
        topSet.drawValuesEnabled = true
        topSet.drawFilledEnabled = true
        topSet.valueTextColor = .white
        topSet.fillAlpha = 0.3
        topSet.fillColor = .black
        topSet.highlightColor = .clear
        topSet.fillFormatter = DefaultFillFormatter { _, _ in CGFloat(self.chartView.rightAxis.axisMaximum) }
        
        // 볼린저밴드 하단
        let bottomBandWidths = Trader.shared.bollingerBands.map { $0.bandWidth.bottom.rounded }
        let bottomEntries = bottomBandWidths.reversed().enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let bottomSet = LineChartDataSet(entries: bottomEntries, label: "Filled Line DataSet Bottom")
        bottomSet.setColor(UIColor.white)
        bottomSet.lineWidth = 1.3
        bottomSet.setCircleColor(.clear)
        bottomSet.circleRadius = 0
        bottomSet.circleHoleRadius = 0
        bottomSet.mode = .cubicBezier
        bottomSet.axisDependency = .right
        bottomSet.drawValuesEnabled = true
        bottomSet.drawFilledEnabled = true
        bottomSet.valueTextColor = .white
        bottomSet.fillAlpha = 0.3
        bottomSet.fillColor = .black
        bottomSet.highlightColor = .clear
        bottomSet.fillFormatter = DefaultFillFormatter { _, _ in CGFloat(self.chartView.rightAxis.axisMinimum)
        }
        
        let chartData = LineChartData(dataSets: [topSet, set, bottomSet])
        
        // 매수평균가 선 (수익률 10% 미만일 때만 보여줌. 안그러면 차트 지나치게 축소됨)
        if Trader.shared.coinBalance > 0, abs(Trader.shared.profitPercent) < 10 {
            let avgBuyPrice = Trader.shared.avgBuyPrice.rounded
            let buyAverageLine = Trader.shared.bollingerBands.map { _ in avgBuyPrice }
            let buyAverageEntries = buyAverageLine.reversed().enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
            let buyAverageSet = LineChartDataSet(entries: buyAverageEntries, label: "Average Buy Line DataSet")
            buyAverageSet.setColor(UIColor.idGreen)
            buyAverageSet.lineWidth = 1.5
            buyAverageSet.setCircleColor(.clear)
            buyAverageSet.circleRadius = 0
            buyAverageSet.circleHoleRadius = 0
            buyAverageSet.mode = .cubicBezier
            buyAverageSet.drawValuesEnabled = true
            buyAverageSet.valueTextColor = .white
            buyAverageSet.highlightColor = .clear
            buyAverageSet.axisDependency = .right
            
            chartData.append(buyAverageSet)
        }
        return chartData
    }
    
    private func generateCandleData() -> CandleChartData {
        let candles = Trader.shared.candles
        let entries = candles.reversed().enumerated().map {
            CandleChartDataEntry(
                x: Double($0),
                shadowH: $1.high_price,
                shadowL: $1.low_price,
                open: $1.opening_price,
                close: $1.trade_price,
                icon: nil
            )
        }
        let set1 = CandleChartDataSet(entries: entries, label: "Candle Data Set")
        set1.axisDependency = .right
        set1.drawIconsEnabled = false
        set1.shadowColorSameAsCandle = true
        set1.shadowWidth = 0.8
        set1.decreasingColor = UIColor.myBlue
        set1.decreasingFilled = true
        set1.increasingColor = UIColor.myRed
        set1.increasingFilled = true
        set1.neutralColor = UIColor.white
        return CandleChartData(dataSet: set1)
    }
}
