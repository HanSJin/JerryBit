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
    var oncePrice: Int { UserDefaultsManager.shared.oncePrice }
    
    // MARK: - Models
    
    // 거래할 코인의 최근 거래 내역
    private var tickerModel: QuoteTickerModel!
    // 거래할 코인의 계좌
    private var tradeAccount: AccountModel!
    // 원화 계좌
    private var krwAccount: AccountModel!
    
    // MARK: - Candles
    
    // 캔들
    static let candleCount = 150
    static let numberOfSkipCandleForMALine = 19
    static var fullCandleCount: Int { candleCount + numberOfSkipCandleForMALine }
    var candles = [QuoteCandleModel]() // 이평선 적용을 위해 가장 과거 19개 candle 을 버린 값
    var fullCandles = [QuoteCandleModel]() // Full 캔들
    
    // Formula - 볼린저밴드
    var bollingerBands = [BollingerBand]()
    
    // Trade Judgement
    var runningTrade = false {
        didSet { print("[Trade Judgement] Running to", runningTrade) }
    }
    var bandWidthPoint: Double { // 현재가 대비 볼린저밴드 폭(표준편차) 의 크기 점수
        guard let band = bollingerBands.first else { return 0.0 }
        let bandDistance = (band.bandWidth.top - band.movingAverage) / BollingerBand.alpha // 표준편차
        return (bandDistance / currentPrice * 100).rounded
    }
    var maJudgementPoint: Double { // 밴드폭 기준으로 현재가의 위치 (-1 ~ +1)
        guard let band = bollingerBands.first else { return 0.0 }
        let bandDistance = band.bandWidth.top - band.movingAverage // 밴드 상(한쪽) 폭
        let maPoint = ((currentPrice - band.movingAverage) / bandDistance).rounded // MA 포인트 (-1 ~ +1)
        return maPoint
    }
    private var tradeTimeRecords = [String]()
    
    // Timer - 경과 시간 기록 & 주문 취소 추적
    private var timer: Timer!
    var timerTick = 0
    var estimatedTradeProfit: Double = 0.0
    
    // 매수 주문 카운트
    var buyRequestCount = 0
    // 매도 주문 카운트
    var sellRequestCount = 0
    
    init() { }
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
        if avgBuyPrice == 0 { return .label }
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

// MARK: - SetUp

extension TradeManager {
    
    func install(market: String) {
        clear()
        self.market = market
        self.runningTrade = false
        
        timer?.invalidate()
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timerTicked), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
    
    private func clear() {
        market = ""
        tradeAccount = nil
        krwAccount = nil
        tickerModel = nil
        timerTick = 0
        timer?.invalidate()
        timer = nil
        estimatedTradeProfit = 0.0
        candles.removeAll()
        fullCandles.removeAll()
        bollingerBands.removeAll()
        buyRequestCount = 0
        sellRequestCount = 0
    }
    
    @objc private func timerTicked() {
        guard runningTrade else { return }
        timerTick += 1
    }
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
    
    func requestOrders(completion: @escaping ([OrderModel]) -> Void) {
        orderService.reuqestOrders(market: market, page: 1, limit: 30).subscribe(onSuccess: {
            switch $0 {
            case .success(let orders):
                completion(orders)
            case .failure(let error):
                completion([])
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            completion([])
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
}

// MARK: - Services Candle
extension TradeManager {
    
    func requestCandles() {
        let unit = UserDefaultsManager.shared.unit
        quoteService.getMinuteCandle(market: market, unit: unit, count: TradeManager.fullCandleCount).subscribe(onSuccess: {
            switch $0 {
            case .success(let candleModels):
                // print("start", Date().toStringWithDefaultFormat())
                TradeManager.shared.fullCandles = candleModels
                TradeManager.shared.candles = Array(candleModels[...(TradeManager.candleCount - 1)])
                TradeManager.shared.bollingerBands = TradeFormula.getBollingerBands(period: TradeManager.numberOfSkipCandleForMALine, type: .normal)
                // print("end", Date().toStringWithDefaultFormat())
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

// MARK: - Services Trade
extension TradeManager {
    
    func requestBuy() {
        guard krwBalance >= Double(oncePrice) else { return }
        guard currentPrice > 0.0 else { return }
        let volume = Double(oncePrice) / currentPrice
        guard volume > 0.0 else { return }
        orderService.requestBuy(market: market, volume: "\(volume)", price: "\(currentPrice)").subscribe(onSuccess: {
            switch $0 {
            case .success(let orderModels):
                TradeManager.shared.buyRequestCount += 1
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
        guard evaluationAmount >= 500.0 else { return } // 최소 주문 금액
        let volume = Double(oncePrice) < evaluationAmount ? (Double(oncePrice) / currentPrice) : tradeAccount.balanceDouble
        
        let profit = (currentPrice - avgBuyPrice) * volume
        estimatedTradeProfit += profit
        
        orderService.requestSell(market: market, volume: "\(volume)", price: "\(currentPrice)").subscribe(onSuccess: {
            switch $0 {
            case .success(let orderModels):
                TradeManager.shared.sellRequestCount += 1
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

// MARK: - Trade Judgement
extension TradeManager {
    
    func tradeJudgement() {
        guard runningTrade else { return }
        
        let maPoint = maJudgementPoint
        print("[Trade Judgement] 현재가: \(currentPrice), MAPoint: \(maPoint)", "BandWidthPoint: \(bandWidthPoint)")

        if maPoint >= 1.0 {
            // bandWidthPoint 가 0.1 미만의 횡보 구간에서 의미없는 매도 Block (현재가 3,000원 일때 bandWidth 가 3원 미만인 경우)
            guard bandWidthPoint > 0.1 else { return }
            
            // 매도 판단
            guard recordTime() else { return }
            print("[Trade Judgement] 매도 요청! \(currentPrice)")
            requestSell()
        } else if maPoint <= -1.0 {
            // 매수 판단
            guard recordTime() else { return }
            print("[Trade Judgement] 매수 요청! \(currentPrice)")
            requestBuy()
        }
    }
    
    // 분으로 구분되는 TimeString 을 Key 로 배열에 Append
    // 배열에 Contains 여부로, 분당 1회 Trade 하도록 조절함.
    func recordTime() -> Bool {
        guard let currentime = Date().toStringWithFormat(to: "yyyy-MM-dd'T'HH:mm") else { return false }
        let recordTime = "\(market)&\(currentime)"
        guard !tradeTimeRecords.contains(recordTime) else { return false }
        tradeTimeRecords.append(recordTime)
        print("[Trade Judgement] Time Records: \(tradeTimeRecords)")
        return true
    }
}
