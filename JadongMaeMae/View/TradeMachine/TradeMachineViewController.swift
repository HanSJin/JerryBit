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
    
    private let market = "KRW-MVL"
    private let oncePrice = 1000
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
        coinNameLabel.text = market
    }
    
    func syncronizeView() {
        coinCurrentPriceLabel.text = TradeManager.shared.currentPrice.numberForm(add: " KRW")
        coinCurrentAvgPriceLabel.text = TradeManager.shared.avgBuyPrice.numberForm(add: " KRW")
        coinCurrentBalanceLabel.text = "\(TradeManager.shared.coinBalance) KRW"
        coinCurrentTotalPriceLabel.text = TradeManager.shared.evaluationAmount.numberForm(add: " KRW")
        
        var krwBalance = TradeManager.shared.krwBalance.numberForm(add: " KRW")
        if TradeManager.shared.krwLocked > 0 {
            krwBalance += "(예약 \(TradeManager.shared.krwLocked.numberForm(add: " KRW"))"
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
    /*
    private func getMinuteCandles() {
//        quoteService.getMinuteCandle(market: "KRW-ETH", unit: 1, count: 200).subscribe {
//            switch $0 {
//            case .success(let quoteModels):
//                print(quoteModels)
//            case .failure(let error):
//                guarerror.globalHandling()
//            }
//        } onError: {
//            prasdasdint($0)
//        }.disposed(by: disposeBag)
    }
}
*/
