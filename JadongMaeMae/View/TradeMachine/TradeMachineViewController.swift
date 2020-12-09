//
//  TradeMachineViewController.swift
//  JadongMaeMae
//
//  Created by USER on 08/12/2020.
//

import UIKit
import RxSwift

class TradeMachineViewController: UIViewController {
    
    // Outlets
    
    // Outlets - KRW Info
    @IBOutlet weak var krwTotalLabel: UILabel!
    
    // Outlets - Coin Info
    @IBOutlet weak var coinCurrentPriceLabel: UILabel!
    @IBOutlet weak var coinCurrentAvgPriceLabel: UILabel!
    @IBOutlet weak var coinCurrentBalanceLabel: UILabel!
    @IBOutlet weak var coinCurrentTotalPriceLabel: UILabel!
    
    // Outlets - Chart
    @IBOutlet weak var chartView: CandleStickChartView!
    
    // Variables
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    private var tradeAccount: AccountModel?
    private var krwAccount: AccountModel?
    private var tickerModel: QuoteTickerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TradeManager.shared.install(market: "KRW-MVL", oncePrice: 1000)
        setUpView()
    }
}

// MARK: - Setup View
extension TradeMachineViewController {
    
    func setUpView() {
        navigationItem.title = TradeManager.shared.market
        setUpChart()
        updateChartData()
    }
    
    func syncronizeView() {
        let trade = TradeManager.shared
        coinCurrentPriceLabel?.text = trade.currentPrice.numberForm(add: "KRW") + " (" + trade.profitSign + trade.profitPercent.numberForm(add: "") + "%)"
        coinCurrentPriceLabel?.textColor = trade.profitColor
        
        coinCurrentAvgPriceLabel?.text = trade.avgBuyPrice.numberForm(add: " KRW")
        coinCurrentBalanceLabel?.text = "\(trade.coinBalance) KRW"
        coinCurrentTotalPriceLabel?.text = trade.evaluationAmount.numberForm(add: " KRW")
        
        var krwBalance = trade.krwBalance.numberForm(add: " KRW")
        if trade.krwLocked > 0 {
            krwBalance += "(예약 \(trade.krwLocked.numberForm(add: " KRW"))"
        }
        krwTotalLabel?.text = krwBalance
    }
}

// MARK: - ChartViewDelegate
extension TradeMachineViewController: ChartViewDelegate {
    
    func setUpChart() {
        chartView.delegate = self
        chartView.chartDescription.enabled = false
        chartView.backgroundColor = #colorLiteral(red: 0.09019607843, green: 0.1411764706, blue: 0.2078431373, alpha: 1)
        
        chartView.maxVisibleCount = 200
        chartView.pinchZoomEnabled = true
        
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
//        chartView.leftAxis.axisMinimum = 0
//        chartView.leftAxis.drawZeroLineEnabled = true
//        chartView.leftAxis.zeroLineWidth = 0.0
        
        chartView.rightAxis.labelFont = UIFont.systemFont(ofSize: 9)
        chartView.rightAxis.labelTextColor = UIColor.white.withAlphaComponent(0.8)
        chartView.rightAxis.spaceTop = 0.3
        chartView.rightAxis.spaceBottom = 0.3
        chartView.rightAxis.axisMinimum = 0
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = UIFont.systemFont(ofSize: 9)
        chartView.xAxis.labelTextColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    func updateChartData() {
        chartView.data = nil
        setDataCount(100, range: 100)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let candles = TradeManager.shared.candles
        let yVals1 = candles.reversed().enumerated().map { (i, candle) -> CandleChartDataEntry in
            CandleChartDataEntry(
                x: Double(i),
                shadowH: candle.high_price.rounded,
                shadowL: candle.low_price.rounded,
                open: candle.opening_price.rounded,
                close: candle.trade_price.rounded,
                icon: nil
            )
        }
        
        let set1 = CandleChartDataSet(entries: yVals1, label: "Data Set")
        set1.axisDependency = .left
//        set1.setColor(UIColor(white: 80/255, alpha: 1))
        set1.drawIconsEnabled = false
        set1.shadowColorSameAsCandle = true
        set1.shadowWidth = 0.5
        set1.decreasingColor = UIColor.myBlue
        set1.decreasingFilled = true
        set1.increasingColor = UIColor.myRed
        set1.increasingFilled = true
        set1.neutralColor = UIColor.white
        
        let data = CandleChartData(dataSet: set1)
        chartView.data = data
    }
}

// MARK: - GlobalRunLoop
extension TradeMachineViewController: GlobalRunLoop {
    
    var fps: Double { 5 }
    func runLoop() {
        TradeManager.shared.syncModels()
        syncronizeView()
    }
    
    var secondaryFps: Double { 1 }
    func secondaryRunLoop() {
        TradeManager.shared.syncCandles()
        updateChartData()
    }
}

// MARK: - UI Touch Events
extension TradeMachineViewController {
    
    @IBAction func tappedBuyButton(_ sender: UIButton) {
        TradeManager.shared.requestBuy()
    }
    
    @IBAction func tappedSellButton(_ sender: UIButton) {
        TradeManager.shared.requestSell()
    }
}
