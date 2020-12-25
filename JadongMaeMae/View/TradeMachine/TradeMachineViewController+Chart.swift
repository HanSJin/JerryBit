//
//  TradeMachineViewController+Chart.swift
//  JadongMaeMae
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
        chartView.maxVisibleCount = TradeManager.candleCount
//        chartView.dragXEnabled = false
        chartView.dragYEnabled = false
//        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
//        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
//        chartView.drawBordersEnabled = true
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
        data.lineData = generateFilledLineData()
        data.candleData = generateCandleData()
        chartView.xAxis.axisMaximum = data.xMax + 0.25
        chartView.data = data
    }
    
    private func generateFilledLineData() -> LineChartData {
        let movingAverageLine = TradeManager.shared.bollingerBands.map { $0.movingAverage }
        let entries = movingAverageLine.reversed().enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        let set = LineChartDataSet(entries: entries, label: "Line DataSet")
        set.setColor(UIColor.white)
        set.lineWidth = 0.8
        set.setCircleColor(.clear)
        set.circleRadius = 0
        set.circleHoleRadius = 0
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.highlightColor = .white
        set.axisDependency = .left
        
        let topBandWidths = TradeManager.shared.bollingerBands.map { $0.bandWidth.top }
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
        topSet.fillAlpha = 0.3
        topSet.fillColor = .black
        topSet.highlightColor = .red
        topSet.fillFormatter = DefaultFillFormatter { _, _ in CGFloat(self.chartView.rightAxis.axisMaximum) }
        
        let bottomBandWidths = TradeManager.shared.bollingerBands.map { $0.bandWidth.bottom }
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
        bottomSet.fillAlpha = 0.3
        bottomSet.fillColor = .black
        bottomSet.highlightColor = .red
        bottomSet.fillFormatter = DefaultFillFormatter { _, _ in CGFloat(self.chartView.rightAxis.axisMinimum)
        }
        return LineChartData(dataSets: [topSet, set, bottomSet])
    }
    
    private func generateCandleData() -> CandleChartData {
        let candles = TradeManager.shared.candles
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
        set1.axisDependency = .left
        set1.drawIconsEnabled = false
        set1.shadowColorSameAsCandle = true
        set1.shadowWidth = 0.5
        set1.decreasingColor = UIColor.myBlue
        set1.decreasingFilled = true
        set1.increasingColor = UIColor.myRed
        set1.increasingFilled = true
        set1.neutralColor = UIColor.white
        return CandleChartData(dataSet: set1)
    }
}
