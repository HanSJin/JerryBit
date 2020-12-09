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
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
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
    }
}

// MARK: - Setup View
extension TradeMachineViewController {
    
    func setUpView() {
        coinNameLabel.text = market
    }
    
    func syncronizeView() {
        if let tickerModel = tickerModel {
            coinCurrentPriceLabel.text = tickerModel.trade_price.numberForm(add: " KRW")
        }
        if let tradeAccount = tradeAccount {
            coinCurrentAvgPriceLabel.text = tradeAccount.avg_buy_price + " KRW"
            coinCurrentBalanceLabel.text = tradeAccount.balance
            let currentTotalPrice = tradeAccount.avgBuyPriceDouble * tradeAccount.balanceDouble
            coinCurrentTotalPriceLabel.text = currentTotalPrice.numberForm(add: " KRW")
        } else {
            coinCurrentAvgPriceLabel.text = "0 KRW"
            coinCurrentBalanceLabel.text = "0"
            coinCurrentTotalPriceLabel.text = "0 KRW"
        }
        if let krwAccount = krwAccount {
            // krwBalanceLabel.text = krwAccount.balance
            if krwAccount.lockedDouble > 0 {
                krwTotalLabel.text = krwAccount.balanceDouble.numberForm(add: " KRW") + "(Lock " + krwAccount.lockedDouble.numberForm(add: " KRW") + ")"
            } else {
                krwTotalLabel.text = krwAccount.balanceDouble.numberForm(add: " KRW")
            }
        }
    }
}

// MARK: - GlobalRunLoop
extension TradeMachineViewController: GlobalRunLoop {
    
    var fps: Double { 5 }
    func runLoop() {
        requestMyAccount() { _ in }
        requestCurrentPrice()
        syncronizeView()
    }
}

// MARK: - UI Touch Events
extension TradeMachineViewController {
    
    @IBAction func tappedBuyButton(_ sender: UIButton) {
        orderService.requestBuy(market: market, price: "\(oncePrice)").subscribe(onSuccess: {
            switch $0 {
            case .success(let orderModels):
                print(orderModels)
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: disposeBag)
    }
    
    @IBAction func tappedSellButton(_ sender: UIButton) {
        guard let tickerModel = tickerModel, tickerModel.trade_price > 0 else { return }
        guard let tradeAccount = tradeAccount else { return }
        let myCoinAmount = (tradeAccount.avgBuyPriceDouble * tradeAccount.balanceDouble)
        let volume: String
        if Double(oncePrice) < myCoinAmount {
            // OncePrice 거래 가능
            volume = "\(Double(oncePrice) / tickerModel.trade_price)"
        } else {
            // OncePrice 거래 잔액 부족
            volume = tradeAccount.balance
        }
        
        orderService.requestSell(market: market, volume: volume).subscribe(onSuccess: {
            switch $0 {
            case .success(let orderModels):
                print(orderModels)
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: disposeBag)
    }
}

// MARK: - Request
extension TradeMachineViewController {
    
    private func requestMyAccount(completion: @escaping ([AccountModel]) -> Void) {
        accountsService.getMyAccounts().subscribe(onSuccess: { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .success(let accountModels):
                self.krwAccount = accountModels.filter { $0.currency == "KRW" }.first
                self.tradeAccount = accountModels.filter { $0.currency == self.market.replacingOccurrences(of: "KRW-", with: "") }.first
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
    
    private func requestCurrentPrice() {
        quoteService.getCurrentPrice(markets: [market]).subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let tickerModels):
                self?.tickerModel = tickerModels.first
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
    
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
