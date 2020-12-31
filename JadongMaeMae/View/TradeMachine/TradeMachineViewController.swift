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
    @IBOutlet private weak var composeButton: UIBarButtonItem!
    @IBOutlet private weak var tradeRunButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView! {
        didSet { tableView.registerNib(cellIdentifier: TradeOrderCell.identifier) }
    }
    @IBOutlet private weak var tableHeaderView: UIView!
    
    // Outlets - KRW Info
    @IBOutlet private weak var krwTotalLabel: UILabel!
    
    // Outlets - Coin Info
    @IBOutlet private weak var coinCurrentPriceLabel: UILabel!
    @IBOutlet private weak var coinCurrentAvgPriceLabel: UILabel!
    @IBOutlet private weak var coinCurrentBalanceLabel: UILabel!
    @IBOutlet private weak var coinCurrentTotalPriceLabel: UILabel!
    
    // Outlets - Auto Trade View
    @IBOutlet private weak var autoTradeView: UIView!
    @IBOutlet private weak var autoTradeHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var autoTradeTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var autoTradeLabel: UILabel!
    @IBOutlet private weak var autoTradeTimerLabel: UILabel!
    @IBOutlet private weak var autoTradeResultLabel: UILabel!
    @IBOutlet private weak var autoTradeMaPoinLabelt: UILabel!
    @IBOutlet private weak var autoTradeBandWidthPointLabel: UILabel!
    @IBOutlet private weak var autoTradeTimeLabel: UILabel!
    @IBOutlet private weak var autoTradeBuyCountLabel: UILabel!
    @IBOutlet private weak var autoTradeSellCountLabel: UILabel!
    
    // Outlets - Chart
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet private weak var unitLabel: UILabel!
    
    @IBOutlet private weak var tradePriceTF: UITextField!
    @IBOutlet private weak var buyButton: UIButton!
    @IBOutlet private weak var sellButton: UIButton!
    
    // Variables
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    private var enableCoin: Bool = false
    private var tradeAccount: AccountModel?
    private var krwAccount: AccountModel?
    private var tickerModel: QuoteTickerModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tradeCoin = UserDefaultsManager.shared.tradeCoin, !tradeCoin.isEmpty else { return }
        enableCoin = true
        TradeManager.shared.install(market: "KRW-\(tradeCoin)")
        setUpView()
        loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        TradeManager.shared.runningTrade = false
    }
    
    deinit {
        print("DEINIT")
    }
}

// MARK: - Setup View
extension TradeMachineViewController {
    
    func setUpView() {
        navigationItem.title = TradeManager.shared.market
        updateRunningButton()
        updateAutoTradeView()
        
        setUpChart()
        updateChartData()
        tradePriceTF.text = "\(TradeManager.shared.oncePrice)"
        
        buyButton.backgroundColor = .myRed
        buyButton.layer.cornerRadius = 10
        sellButton.backgroundColor = .myBlue
        sellButton.layer.cornerRadius = 10
    }
    
    func syncronizeView() {
        let trade = TradeManager.shared
        coinCurrentPriceLabel?.text = trade.currentPrice.numberForm(add: "KRW") + " (" + trade.profitSign + trade.profitPercent.numberForm(add: "") + "%)"
        
        coinCurrentAvgPriceLabel?.text = trade.avgBuyPrice.numberForm(add: " KRW")
        coinCurrentBalanceLabel?.text = "\(trade.coinBalance)"
        let profit = NumberFormatter.decimal(Int(trade.evaluationAmount - trade.coinBuyAmmount))
        coinCurrentTotalPriceLabel?.text = trade.evaluationAmount.numberForm(add: "") + "(\(trade.profitSign)\(profit)) KRW"
        // coinCurrentTotalPriceLabel?.textColor = trade.profitColor
        
        var krwBalance = trade.krwBalance.numberForm(add: " KRW")
        if trade.krwLocked > 0 {
            krwBalance += "(예약 \(trade.krwLocked.numberForm(add: " KRW)"))"
        }
        krwTotalLabel?.text = krwBalance
    }
    
    private func updateRunningButton() {
        if TradeManager.shared.runningTrade {
            if #available(iOS 13.0, *) {
                tradeRunButton.image = UIImage(systemName: "pause.fill")
            } else {
                tradeRunButton.title = "Pause"
            }
        } else {
            if #available(iOS 13.0, *) {
                tradeRunButton.image = UIImage(systemName: "play.fill")
            } else {
                tradeRunButton.title = "Play"
            }
        }
    }
    
    private func updateAutoTradeView() {
        if TradeManager.shared.runningTrade {
            autoTradeHeightConstraint.constant = 40
            autoTradeTopConstraint.constant = 2
            autoTradeView.isHidden = false
            tableHeaderView.frame.size.height = 403
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse, .repeat]) {
                self.autoTradeLabel.alpha = 0.2
            } completion: { _ in }
        } else {
            autoTradeHeightConstraint.constant = 0
            autoTradeTopConstraint.constant = 0
            autoTradeView.isHidden = true
            tableHeaderView.frame.size.height = 403 - 40 - 2
        }
        view.layoutSubviews()
        tableView.reloadData()
    }
    
    private func updateTradeTimerTick() {
        let time = secondsToHoursMinutesSeconds(seconds: TradeManager.shared.timerTick)
        autoTradeTimerLabel.text = "\(String(format: "%02d", time.0)):\(String(format: "%02d", time.1)):\(String(format: "%02d", time.2))"
        autoTradeTimeLabel.text = Date().toStringWithFormat(to: "HH:mm:ss")
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func updateTradeEstimatedProfit() {
        let estimatedTradeProfit = TradeManager.shared.estimatedTradeProfit
        autoTradeResultLabel.text = "\(estimatedTradeProfit > 0 ? "+" : "")\(estimatedTradeProfit.numberForm(add: " KRW"))"
    }
    
    private func updateTradePoints() {
        autoTradeMaPoinLabelt.text = "\(String(format: "%.2f", TradeManager.shared.maJudgementPoint.rounded))"
        autoTradeBandWidthPointLabel.text = "\(String(format: "%.2f", TradeManager.shared.bandWidthPoint.rounded))"
        autoTradeBuyCountLabel.text = "\(TradeManager.shared.buyOrderIds.count)회"
        autoTradeSellCountLabel.text = "\(TradeManager.shared.sellOrderIds.count)회"
    }
    
    private func loadData() { }
}

// MARK: - GlobalRunLoop
extension TradeMachineViewController: GlobalRunLoop {
    
    var fps: Double { 2 }
    func runLoop() {
        guard enableCoin else { return }
        TradeManager.shared.syncModels()
        unitLabel.text = "\(UserDefaultsManager.shared.unit)분"
        syncronizeView()
        updateTradeTimerTick()
        updateTradeEstimatedProfit()
        updateTradePoints()
    }
    
    var secondaryFps: Double { 1 }
    func secondaryRunLoop() {
        guard enableCoin else { return }
        TradeManager.shared.requestCandles { [weak self] in
            self?.updateChartData()
        }
        TradeManager.shared.requestOrders() { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension TradeMachineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TradeManager.shared.tradeOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TradeOrderCell = tableView.dequeueReusableCell(for: indexPath),
              let orderModel = TradeManager.shared.tradeOrders[safe: indexPath.row] else { return tableView.emptyCell }
        cell.updateView(orderModel)
        return cell
    }
}

// MARK: - UITableViewDataSource
extension TradeMachineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let orderModel = TradeManager.shared.tradeOrders[safe: indexPath.row] else { return }
        guard orderModel.state == "wait" else { return }
        
        let alert = UIAlertController(title: "주문 삭제", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .default) { _ in
            TradeManager.shared.requestCancelOrder(uuid: orderModel.uuid)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UI Touch Events
extension TradeMachineViewController {
    
    @objc func tappedTradeRunningButton(_ sender: UIBarButtonItem) {
        TradeManager.shared.runningTrade = !TradeManager.shared.runningTrade
        updateRunningButton()
        updateAutoTradeView()
    }
    
    @IBAction func tappedSaveOncePriceButton(_ sender: UIButton) {
        guard let oncePriceText = tradePriceTF.text, let oncePrice = Int(oncePriceText), oncePrice >= 500 else {
            UIAlertController.simpleAlert(message: "최저 거래 대금 500원 이상을 입력해주세요.")
            return
        }
        UserDefaultsManager.shared.oncePrice = oncePrice
        UIAlertController.simpleAlert(message: "\(oncePrice)원 저장~")
    }
    
    @IBAction func tappedComposeButton(_ sender: UIBarButtonItem) {
        let optionAlert = UIAlertController(title: "분봉 길이", message: nil, preferredStyle: .actionSheet)
        let units = [1, 3, 5, 10, 15, 30, 60, 240]
        units.forEach { unit in
            let unitText = unit >= 60 ? "\(unit / 60)시간" : "\(unit)분"
            optionAlert.addAction(UIAlertAction(title: unitText, style: .default) { _ in
                UserDefaultsManager.shared.unit = unit
            })
        }
        optionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = optionAlert.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(optionAlert, animated: true, completion: nil)
            }
        } else {
            present(optionAlert, animated: true)
        }
    }
    
    @IBAction func tappedBuyButton(_ sender: UIButton) {
        TradeManager.shared.requestBuy()
    }
    
    @IBAction func tappedSellButton(_ sender: UIButton) {
        TradeManager.shared.requestSell()
    }
}
