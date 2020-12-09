//
//  TradeMachineViewController.swift
//  JadongMaeMae
//
//  Created by USER on 08/12/2020.
//

import UIKit
import RxSwift
import UIKit

class TradeMachineViewController: UIViewController {
    
    // Outlets
    // Outlets - Coin Info
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinCurrentPriceLabel: UILabel!
    @IBOutlet weak var coinCurrentAvgPriceLabel: UILabel!
    @IBOutlet weak var coinCurrentBalanceLabel: UILabel!
    @IBOutlet weak var coinCurrentTotalPriceLabel: UILabel!
    
    // Outlets - KRW Info
    @IBOutlet weak var krwTotalLabel: UILabel!
    
    // Variables
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    private var tradeAccount: AccountModel?
    private var krwAccount: AccountModel?
    private var tickerModel: QuoteTickerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        TradeManager.shared.install(market: "KRW-MVL", oncePrice: 1000)
    }
}

// MARK: - Setup View
extension TradeMachineViewController {
    
    func setUpView() {
        coinNameLabel.text = TradeManager.shared.market
    }
    
    func syncronizeView() {
        let trade = TradeManager.shared
        coinCurrentPriceLabel.text = trade.currentPrice.numberForm(add: "KRW") + " (" + trade.profitSign + trade.profitPercent.numberForm(add: "") + "%)"
        coinCurrentPriceLabel.textColor = trade.profitColor
        
        coinCurrentAvgPriceLabel.text = trade.avgBuyPrice.numberForm(add: " KRW")
        coinCurrentBalanceLabel.text = "\(trade.coinBalance) KRW"
        coinCurrentTotalPriceLabel.text = trade.evaluationAmount.numberForm(add: " KRW")
        
        var krwBalance = trade.krwBalance.numberForm(add: " KRW")
        if trade.krwLocked > 0 {
            krwBalance += "(예약 \(trade.krwLocked.numberForm(add: " KRW"))"
        }
        krwTotalLabel.text = krwBalance
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
