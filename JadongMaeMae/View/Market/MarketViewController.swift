//
//  MarketViewController.swift
//  JadongMaeMae
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
            //tableView.registerNib(cellIdentifier: MyAccountCell.identifier)
            tableView.registerNib(cellIdentifier: MarketCoinCell.identifier)
        }
    }
    
    // Variables
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private var disposeBag = DisposeBag()
    
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
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension MarketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MarketAll.shared.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MarketCoinCell = tableView.dequeueReusableCell(for: indexPath),
              let coinModel = MarketAll.shared.coins[safe: indexPath.row] else { return tableView.emptyCell }
        cell.textLabel?.text = coinModel.coinName //
        return cell
    }
}

// MARK: - UITableViewDataSource
extension MarketViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Request
extension MarketViewController {
    
    private func requestMarketAll() {
        quoteService.getMarketAllCoins().subscribe(onSuccess: {
            switch $0 {
            case .success(let coinModels):
                MarketAll.shared.coins = coinModels
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
