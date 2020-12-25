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
    @IBOutlet weak var tableView: UITableView! {
        didSet { tableView.registerNib(cellIdentifier: TradeOrderCell.identifier) }
    }
    
    // Outlets - KRW Info
    @IBOutlet private weak var krwTotalLabel: UILabel!
    
    // Outlets - Coin Info
    @IBOutlet private weak var coinCurrentPriceLabel: UILabel!
    @IBOutlet private weak var coinCurrentAvgPriceLabel: UILabel!
    @IBOutlet private weak var coinCurrentBalanceLabel: UILabel!
    @IBOutlet private weak var coinCurrentTotalPriceLabel: UILabel!
    
    // Outlets - Chart
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet weak var tradePriceTF: UITextField!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    // Variables
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    private var enableCoin: Bool = false
    private var tradeAccount: AccountModel?
    private var krwAccount: AccountModel?
    private var tickerModel: QuoteTickerModel?
    private var tradeOrders: [OrderModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tradeCoin = UserDefaultsManager.shared.tradeCoin, !tradeCoin.isEmpty else { return }
        enableCoin = true
        TradeManager.shared.install(market: "KRW-\(tradeCoin)", oncePrice: 1000)
        setUpView()
        loadData()
    }
}

// MARK: - Setup View
extension TradeMachineViewController {
    
    func setUpView() {
        navigationItem.title = TradeManager.shared.market
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
        coinCurrentPriceLabel?.textColor = trade.profitColor
        
        coinCurrentAvgPriceLabel?.text = trade.avgBuyPrice.numberForm(add: " KRW")
        coinCurrentBalanceLabel?.text = "\(trade.coinBalance)"
        coinCurrentTotalPriceLabel?.text = trade.evaluationAmount.numberForm(add: " KRW")
        
        var krwBalance = trade.krwBalance.numberForm(add: " KRW")
        if trade.krwLocked > 0 {
            krwBalance += "(예약 \(trade.krwLocked.numberForm(add: " KRW)"))"
        }
        krwTotalLabel?.text = krwBalance
    }
    
    private func loadData() {
        
    }
}

// MARK: - GlobalRunLoop
extension TradeMachineViewController: GlobalRunLoop {
    
    var fps: Double { 2 }
    func runLoop() {
        guard enableCoin else { return }
        TradeManager.shared.syncModels()
        unitLabel.text = "\(UserDefaultsManager.shared.unit)분"
        syncronizeView()
    }
    
    var secondaryFps: Double { 1 }
    func secondaryRunLoop() {
        guard enableCoin else { return }
        TradeManager.shared.syncCandles()
        updateChartData()
        TradeManager.shared.requestOrders { [weak self] in
            self?.tradeOrders = $0
            self?.tableView.reloadData()
        }
        TradeManager.shared.tradeJudgement()
    }
}

// MARK: - UITableViewDataSource
extension TradeMachineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tradeOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TradeOrderCell = tableView.dequeueReusableCell(for: indexPath),
              let orderModel = tradeOrders[safe: indexPath.row] else { return tableView.emptyCell }
        cell.updateView(orderModel)
        return cell
    }
}

// MARK: - UITableViewDataSource
extension TradeMachineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UI Touch Events
extension TradeMachineViewController {
    
    @IBAction func tappedComposeButton(_ sender: UIBarButtonItem) {
        let optionAlert = UIAlertController(title: "분봉 길이", message: nil, preferredStyle: .actionSheet)
        optionAlert.addAction(UIAlertAction(title: "1분", style: .default) { _ in
            UserDefaultsManager.shared.unit = 1
        })
        optionAlert.addAction(UIAlertAction(title: "10분", style: .default) { _ in
            UserDefaultsManager.shared.unit = 10
        })
        optionAlert.addAction(UIAlertAction(title: "60분", style: .default) { _ in
            UserDefaultsManager.shared.unit = 60
        })
        optionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(optionAlert, animated: true)
    }
    
    @IBAction func tappedBuyButton(_ sender: UIButton) {
        TradeManager.shared.requestBuy()
    }
    
    @IBAction func tappedSellButton(_ sender: UIButton) {
        TradeManager.shared.requestSell()
    }
}
