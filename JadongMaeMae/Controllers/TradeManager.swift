//
//  TradeManager.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/10.
//

import Foundation
import RxCocoa
import RxSwift

class TradeManager {
    
    static let shared = TradeManager()
    
    // MARK: - Private
    
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    // MARK: - Variables
    
    // 거래 Market
    private var market: String = "" // "KRW-MVL"
    // 1회 거래 가능량
    private var oncePrice: Int = 0 // 1000
    
    // MARK: - Models
    
    // 거래할 코인의 최근 거래 내역
    private var tickerModel: QuoteTickerModel!
    // 거래할 코인의 계좌
    private var tradeAccount: AccountModel!
    // 원화 계좌
    private var krwAccount: AccountModel!
    
    init() { }
}

// MARK: - SetUp

extension TradeManager {
    
    func install(market: String, oncePrice: Int) {
        clear()
        self.market = market
        self.oncePrice = oncePrice
    }
    
    private func clear() {
        market = ""
        oncePrice = 0
        tradeAccount = nil
        krwAccount = nil
        tickerModel = nil
    }
}

// MARK: - Coin & Price Infomation
extension TradeManager {
    
    // MARK: - About Coin
    // 현재가
    var currentPrice: Double { tickerModel?.trade_price ?? 0.0 }
    // 평균 매수가
    var avgBuyPrice: Double { tradeAccount?.avgBuyPriceDouble ?? 0.0 }
    // 코인 보유량
    var coinBalance: Double { tradeAccount?.balanceDouble ?? 0.0 }
    // 평가 금액
    var evaluationAmount: Double { (tradeAccount?.avgBuyPriceDouble ?? 0.0) * (tradeAccount?.balanceDouble ?? 0.0) }
    
    // MARK: - About KRW
    // 원화 보유량
    var krwBalance: Double { krwAccount?.balanceDouble ?? 0.0 }
    // 원화 매매 예약금
    var krwLocked: Double { krwAccount?.lockedDouble ?? 0.0 }
}

// MARK: - Services Syncronize
extension TradeManager {
    
    func syncModels() {
        requestMyAccount()
        requestTickerModel()
    }
    
    private func requestMyAccount() {
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
    
    private func requestTickerModel() {
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
}

// MARK: Services Trade
extension TradeManager {
    
    func requestBuy() {
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
    
    func requestSell() {
        let volume: String = Double(oncePrice) < evaluationAmount ? "\(Double(oncePrice) / currentPrice)" : tradeAccount.balance 
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
