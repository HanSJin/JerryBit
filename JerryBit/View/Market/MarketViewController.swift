//
//  MarketViewController.swift
//  JerryBit
//
//  Created by SJin Han on 2021/05/05.
//

import RxCocoa
import RxSwift
import UIKit

class MarketViewController: UIViewController {

    // Outelts
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(cellIdentifier: MarketCoinCell.identifier)
        }
    }
    
    // Variables
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private var disposeBag = DisposeBag()
    
    private var marketModels: [MarketModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpMarketAll()
    }
}

// MARK: - Setup View
extension MarketViewController {
    
    func setUpView() {
        title = "마켓"
    }
    
    func setUpMarketAll() {
        guard MarketAll.shared.coins.isEmpty else { return }
        requestMarketAll()
    }
}

// MARK: - GlobalRunLoop
extension MarketViewController: GlobalRunLoop {
    
    var fps: Double { 2 }
    func runLoop() {
        guard !MarketAll.shared.coins.isEmpty else { return }
        requestCurrentPrices(coins: MarketAll.shared.coins.map { $0.market })
    }
}

// MARK: - UITableViewDataSource
extension MarketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MarketAll.shared.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MarketCoinCell = tableView.dequeueReusableCell(for: indexPath),
              let marketModel = marketModels[safe: indexPath.row] else { return tableView.emptyCell }
        cell.model = marketModel
        return cell
    }
}

// MARK: - UITableViewDataSource
extension MarketViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currency = marketModels[safe: indexPath.row]?.coinMarketInfo?.coinName else { return }
        moveToTradeMachine(currency: currency)
    }
    
    private func moveToTradeMachine(currency: String) {
        UserDefaultsManager.shared.tradeCoin = currency
        let tradeMachineVC = UIStoryboard(name: "TradeMachine", bundle: nil).instantiateInitialViewController() as! TradeMachineViewController
        tradeMachineVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(tradeMachineVC, animated: true)
    }
}

// MARK: - Request
extension MarketViewController {
    
    private func requestMarketAll() {
        quoteService.getMarketAllCoins().subscribe(onSuccess: {
            switch $0 {
            case .success(let coinModels):
                MarketAll.shared.coins = coinModels.filter { $0.marketKind == "KRW" }
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
    
    private func requestCurrentPrices(coins: [String]) {
        quoteService.getCurrentPrice(markets: coins).subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let tickerModels):
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.joinMarketModel(tickerModels: tickerModels)
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                if error.globalHandling() { return }
                // Addtional Handling
            }
        }) { error in
            if error.globalHandling() { return }
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
    
    private func joinMarketModel(tickerModels: [QuoteTickerModel]) {
        var marketModels: [MarketModel] = []
        for coin in MarketAll.shared.coins {
            let marketModel = MarketModel(
                quoteTickerModel: tickerModels.filter { $0.market == coin.market}.first,
                coinMarketInfo: coin
            )
            marketModels.append(marketModel)
        }
        marketModels.sort { $0.quoteTickerModel!.acc_trade_price_24h > $1.quoteTickerModel!.acc_trade_price_24h }
        self.marketModels = marketModels
    }
}
