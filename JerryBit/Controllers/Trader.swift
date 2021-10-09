//
//  Trader.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/10.
//

import Foundation
import RxCocoa
import RxSwift

typealias Completion = () -> Void

class Trader {
    
    static let shared = Trader()
    
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
    var tradeOrders = [OrderModel]() // 주문 내역
    
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
    
    // 매매 시작 원화 계산 / 기록
    var totalAmount: Double {
        guard let tradeAccount = tradeAccount else { return 0.0 }
        let buyWaiting = tradeOrders.filter { $0.state == "wait" && $0.side == "bid" }.map { $0.lockedDouble }.reduce(0.0, +)
        let sellWaiting = tradeAccount.lockedDouble * tradeAccount.avgBuyPriceDouble
        return krwBalance + evaluationAmount + buyWaiting + sellWaiting
    }
    var recordedTotalAmount = Double(0.0)
    
    // 매수 주문 카운트
    var buyOrderIds = [String]()
    // 매도 주문 카운트
    var sellOrderIds = [String]()
    // 주문 취소 카운트
    var cancelOrderIds = [String]()
    
    init() {
        timer?.invalidate()
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timerTicked), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
}

// MARK: - Coin & Price Infomation
extension Trader {
    
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
    // 매수 예약된 코인 갯수
    var coinLocked: Double { tradeAccount?.lockedDouble ?? 0.0 }
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
        if avgBuyPrice == 0 { return UIColor.MyColor.label }
        if currentPrice == avgBuyPrice {
            return UIColor.MyColor.label
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

extension Trader {
    
    func install(market: String) {
        if self.market != market {
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(200)) { [weak self] in
                self?.clear()
            }
            clear()
        }
        self.market = market
        self.runningTrade = false
    }
    
    private func clear() {
        tradeAccount = nil
        krwAccount = nil
        tickerModel = nil
        timerTick = 0
        candles.removeAll()
        fullCandles.removeAll()
        bollingerBands.removeAll()
        buyOrderIds.removeAll()
        sellOrderIds.removeAll()
        cancelOrderIds.removeAll()
        recordedTotalAmount = 0.0
    }
    
    @objc private func timerTicked() {
        guard runningTrade else { return }
        timerTick += 1
        tradeJudgement()
        findCancelableOrder()
        setRecorededTotalAmount()
    }
    
    private func setRecorededTotalAmount() {
        guard recordedTotalAmount == 0.0 else { return }
        guard tradeAccount != nil, krwAccount != nil, tickerModel != nil, !tradeOrders.isEmpty else { return }
        recordedTotalAmount = totalAmount
    }
}

// MARK: - Services Syncronize
extension Trader {
    
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
        quoteService.getCurrentPrice(markets: [market]).subscribe(onSuccess: {
            switch $0 {
            case .success(let tickerModels):
                Trader.shared.tickerModel = tickerModels.first
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
    
    func requestOrders(completion: @escaping Completion) {
        orderService.requestOrdersWithDone(market: market, page: 1, limit: 30).subscribe(onSuccess: { [unowned self] in
            switch $0 {
            case .success(let doneOrders):
                orderService.requestOrdersWithNotAssigned(market: market, page: 1, limit: 30).subscribe(onSuccess: {
                    switch $0 {
                    case .success(let notAssignedOrders):
                        var orders = doneOrders + notAssignedOrders
                        orders.sort {
                            $0.created_at.toDateWithDefaultFormat()! > $1.created_at.toDateWithDefaultFormat()!
                        }
                        Trader.shared.tradeOrders = orders
                        completion()
                    case .failure(let error):
                        if error.globalHandling() { return }
                        // Addtional Handling
                    }
                }) { error in
                    if error.globalHandling() { return }
                    // Addtional Handling
                }.disposed(by: self.disposeBag)
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

// MARK: - Services Candle
extension Trader {
    
    func requestCandles(completion: @escaping Completion) {
        let unit = UserDefaultsManager.shared.unit
        quoteService.getMinuteCandle(market: market, unit: unit, count: Trader.fullCandleCount).subscribe(onSuccess: {
            switch $0 {
            case .success(let candleModels):
                // print("start", Date().toStringWithDefaultFormat())
                Trader.shared.fullCandles = candleModels
                Trader.shared.candles = Array(candleModels[...(Trader.candleCount - 1)])
                Trader.shared.bollingerBands = TradeFormula.getBollingerBands(period: Trader.numberOfSkipCandleForMALine, type: .normal)
                // print("end", Date().toStringWithDefaultFormat())
                completion()
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
extension Trader {
    typealias IntCompletion = (Int) -> Void
    
    func requestBuy(completion: IntCompletion? = nil) {
        guard krwBalance >= Double(oncePrice) else { return }
        guard currentPrice > 0.0 else { return }
        
        guard Double(UserDefaultsManager.shared.maxCoinBuyAmmount) > (coinBuyAmmount + Double(oncePrice)) else {
            UIAlertController.simpleAlert(message: "최대 매수 가능 금액 초과")
            return
        }
        
        let volume = Double(oncePrice) / currentPrice
        guard volume > 0.0 else { return }
        orderService.requestBuy(market: market, volume: "\(volume)", price: "\(currentPrice)").subscribe(onSuccess: {
            switch $0 {
            case .success(let orderModel):
                Trader.shared.buyOrderIds.append(orderModel.uuid)
                completion?(Int(volume * Trader.shared.currentPrice))
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: disposeBag)
    }
    
    func requestSell(completion: IntCompletion? = nil) {
        guard evaluationAmount >= 500.0 else { return } // 최소 주문 금액
        let volume = Double(oncePrice) < evaluationAmount ? (Double(oncePrice) / currentPrice) : tradeAccount.balanceDouble
        
        orderService.requestSell(market: market, volume: "\(volume)", price: "\(currentPrice)").subscribe(onSuccess: {
            switch $0 {
            case .success(let orderModel):
                Trader.shared.sellOrderIds.append(orderModel.uuid)
                completion?(Int(volume * Trader.shared.currentPrice))
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
extension Trader {
    
    func tradeJudgement() {
        guard runningTrade else { return }
        guard bandWidthPoint > 0.2 else { return }
        
        let maPoint = maJudgementPoint
        let limit = Double(oncePrice * 30)
        
        print("[Trade Judgement] 현재가: \(currentPrice), MAPoint: \(maPoint)", "BandWidthPoint: \(bandWidthPoint)")
        
        let buy = { [unowned self] in
            guard self.recordTime() else { return }
            print("[Trade Judgement] 매수 요청! \(self.currentPrice)")
            self.requestBuy()
        }
        let sell = { [unowned self] in
            guard self.recordTime() else { return }
            print("[Trade Judgement] 매도 요청! \(self.currentPrice)")
            self.requestSell()
        }
        
        // 적극 매수
        if evaluationAmount < limit, maPoint <= -0.95 {
            buy() // 보유 코인이 limit 보다 적으면 적극 매수
        }
        // 매수
        else if maPoint <= -1.0 {
            buy()
        }
        // 적극 매도
        else if krwBalance < limit * 1.5, maPoint >= 0.95 {
            sell() // 보유 원화가 limit 보다 적으면 적극 매도
        }
        // 매도
        else if maPoint >= 1.0 {
            sell()
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

// MARK: - Cancel Order
extension Trader {
    
    private func findCancelableOrder() {
        let _ = tradeOrders.filter { $0.state == "wait" }
            .filter {
                guard let createdDate = $0.created_at.toDateWithDefaultFormat() else { return false }
                return Date().timeIntervalSince(createdDate) > (60 * 5)
            }
            .map { [weak self] in self?.requestCancelOrder(uuid: $0.uuid) }
    }
    
    func requestCancelOrder(uuid: String) {
        orderService.requestCancelOrder(uuid: uuid).subscribe(onSuccess: { _ in
            Trader.shared.cancelOrderIds.append(uuid)
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
}
