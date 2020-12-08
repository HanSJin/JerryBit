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
    @IBOutlet weak var krwBalanceLabel: UILabel!
    @IBOutlet weak var krwLockedLabel: UILabel!
    @IBOutlet weak var krwTotalLabel: UILabel!
    
    // Variables
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    // private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    private let market = "KRW-EOS"
    private var tradeAccount: AccountModel?
    private var krwAccount: AccountModel?
    
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
        if let tradeAccount = tradeAccount {
            coinCurrentPriceLabel.text = ""
            coinCurrentAvgPriceLabel.text = tradeAccount.avg_buy_price
            coinCurrentBalanceLabel.text = tradeAccount.balance
        }
        if let krwAccount = krwAccount {
            // krwBalanceLabel.text = krwAccount.balance
            krwLockedLabel.text = krwAccount.locked
            krwTotalLabel.text = krwAccount.balance
        }
    }
}

// MARK: - GlobalRunLoop
extension TradeMachineViewController: GlobalRunLoop {
    
    var fps: Double { 8 }
    func runLoop() {
        requestMyAccount() { _ in }
        syncronizeView()
    }
}

// MARK: - UI Touch Events
extension TradeMachineViewController {
    
    @IBAction func tappedBuyButton(_ sender: UIButton) {
        orderService.requestBuy(market: market, price: "1000").subscribe(onSuccess: {
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
        orderService.requestSell(market: market, volume: "1.0").subscribe(onSuccess: {
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
