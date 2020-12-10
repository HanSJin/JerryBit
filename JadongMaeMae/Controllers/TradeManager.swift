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
    var market: String = "" // "KRW-MVL"
    // 1회 거래 가능량
    private var oncePrice: Int = 0 // 1000
    
    // MARK: - Models
    
    // 거래할 코인의 최근 거래 내역
    private var tickerModel: QuoteTickerModel!
    // 거래할 코인의 계좌
    private var tradeAccount: AccountModel!
    // 원화 계좌
    private var krwAccount: AccountModel!
    
    // MARK: - Candles
    
    // 캔들
    var candles = [QuoteCandleModel]()
    
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
        candles.removeAll()
    }
}

// MARK: - Coin & Price Infomation
extension TradeManager {
    
    enum CoinChangeSign: String {
        case EVEN // 보합
        case RISE // 상승
        case FALL // 하락
    }
    
    // MARK: - About Coin
    // 현재가
    var currentPrice: Double { tickerModel?.trade_price ?? 0.0 }
    // 평균 매수가
    var avgBuyPrice: Double { tradeAccount?.avgBuyPriceDouble ?? 0.0 }
    // 코인 보유량
    var coinBalance: Double { tradeAccount?.balanceDouble ?? 0.0 }
    // 총 매수 금액
    var coinBuyAmmount: Double { avgBuyPrice * coinBalance }
    // 평가 금액
    var evaluationAmount: Double { currentPrice * coinBalance }
    // 평가 손익 퍼센트
    var profitPercent: Double {
        if avgBuyPrice == 0 { return 0.0 }
        return (currentPrice / avgBuyPrice) * 100 - 100
    }
    // 평가 손익 부호 (양수일 때만 '+' 반환)
    var profitSign: String { profitPercent > 0 ? "+" : "" }
    // 평가 손익 색상 (검/빨/파)
    var profitColor: UIColor {
        if avgBuyPrice == 0 { return .black }
        if currentPrice == avgBuyPrice {
            return UIColor.label
        } else if currentPrice > avgBuyPrice {
            return .myRed
        } else {
            return .myBlue
        }
    }
    
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
    
    func syncCandles() {
        requestCandles()
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
        quoteService.getCurrentPrice(markets: [market]).subscribe(onSuccess: {
            switch $0 {
            case .success(let tickerModels):
                TradeManager.shared.tickerModel = tickerModels.first
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

// MARK: Services Candle
extension TradeManager {
    
    func requestCandles() {
        quoteService.getMinuteCandle(market: market, unit: 1, count: 200).subscribe(onSuccess: {
            switch $0 {
            case .success(let candleModels):
                TradeManager.shared.candles = candleModels
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
