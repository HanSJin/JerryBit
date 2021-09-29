//
//  MyAccountViewController.swift
//  JerryBit
//
//  Created by USER on 2020/12/07.
//

import RxCocoa
import RxSwift
import UIKit

class MyAccountViewController: BaseViewController {

    // Outelts
    @IBOutlet private weak var settingBarButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView! {
        didSet { tableView.registerNib(cellIdentifier: MyAccountCell.identifier) }
    }
    @IBOutlet weak var totalAccount: UILabel!
    @IBOutlet weak var krwBalanceLabel: UILabel!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var tradeMachineButton: UIButton! {
        didSet { tradeMachineButton.layer.cornerRadius = 8.0 }
    }
    @IBOutlet weak var tradeNameTF: UITextField!
    
    // Variables
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private var disposeBag = DisposeBag()
    
    private var accountModels: [AccountModel] = []
    private var krwAccountModel: AccountModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpMarketAll()
    }
}

// MARK: - Setup View
extension MyAccountViewController {
    
    func setUpView() {
        title = "내 계좌"
        tradeNameTF.text = UserDefaultsManager.shared.tradeCoin
        requestMyAccount { [weak self] accountModels in
            self?.requestCurrentPrice(accountModels: accountModels)
        }
    }
}

// MARK: - Setup Market
extension MyAccountViewController {

    func setUpMarketAll() {
        guard MarketAll.shared.coins.isEmpty else { return }
        requestMarketAll()
    }
}

// MARK: - GlobalRunLoop
extension MyAccountViewController: GlobalRunLoop {
    
    var fps: Double { 2 }
    func runLoop() {
        guard !MarketAll.shared.coins.isEmpty else { return }
        requestMyAccount { [weak self] accountModels in
            self?.requestCurrentPrice(accountModels: accountModels)
        }
        let totalAccountAmount = Int(accountModels.map { $0.currentTotalPrice }.reduce(0.0) { Double($0) + Double($1) })
        totalAccount.text = NumberFormatter.decimal(totalAccountAmount) + " 원"
        krwBalanceLabel.text = krwAccountModel?.balanceDouble.numberForm(add: " 원")
        let totalMoney = Double(totalAccountAmount) + (krwAccountModel?.balanceDouble ?? 0)
        totalMoneyLabel.text = totalMoney.numberForm(add: " 원")
    }
}

// MARK: - UITableViewDataSource
extension MyAccountViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyAccountCell = tableView.dequeueReusableCell(for: indexPath),
              let account = accountModels[safe: indexPath.row] else { return tableView.emptyCell }
        cell.updateView(account)
        return cell
    }
}

// MARK: - UITableViewDataSource
extension MyAccountViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let account = accountModels[safe: indexPath.row] else { return }
        tradeNameTF.text = account.currency
        moveToTradeMachine(currency: account.currency)
    }
}

// MARK: - UI Touch Events
extension MyAccountViewController {
    
    @IBAction func tappedTradeMachineButton(_ sender: UIButton) {
        guard let currency = tradeNameTF.text, !currency.isEmpty else { return }
        moveToTradeMachine(currency: currency.uppercased())
    }
    
    private func moveToTradeMachine(currency: String) {
        UserDefaultsManager.shared.tradeCoin = currency
        let tradeMachineVC = UIStoryboard(name: "TradeMachine", bundle: nil).instantiateInitialViewController() as! TradeMachineViewController
        tradeMachineVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(tradeMachineVC, animated: true)
    }
    
    @IBAction func tappedSettingBarButton(_ sender: UIBarButtonItem) {
        let optionAlert = UIAlertController(title: "설정", message: nil, preferredStyle: .actionSheet)
        optionAlert.addAction(UIAlertAction(title: "매수 가능 최대 금액 설정", style: .default) { _ in
            self.showMaximumCoinBuyAmmountPrompt()
        })
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
    
    private func showMaximumCoinBuyAmmountPrompt() {
        let alert = UIAlertController(title: "코인 매수 최대 금액 설정", message: "설정 금액 초과 시, 매수 입력을 무시함\n자동매매는 지속되니까 걱정ㄴㄴ에요 유유", preferredStyle: .alert)
        let ok = UIAlertAction(title: "저장", style: .default) { _ in
            guard let amount = alert.textFields?[0].text, let amountInt = Int(amount), amountInt > 1000 else {
                UIAlertController.simpleAlert(message: "똑바른 금액으로 다시 입력")
                return
            }
            UserDefaultsManager.shared.maxCoinBuyAmmount = amountInt
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addTextField {
            $0.keyboardType = .numberPad
            $0.placeholder = "\(NumberFormatter.decimal(UserDefaultsManager.shared.maxCoinBuyAmmount))"
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

// MARK: - Request
extension MyAccountViewController {
    
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
    
    private func requestMyAccount(completion: @escaping ([AccountModel]) -> Void) {
        accountsService.getMyAccounts().subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let accountModels):
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.krwAccountModel = accountModels.filter { $0.currency == "KRW" }.first
                    for model in accountModels {
                        model.coinMarketInfo = MarketAll.shared.getCoin(currency: model.currency)
                    }
                    completion(accountModels.filter { $0.coinMarketInfo != nil })
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
    
    private func requestCurrentPrice(accountModels: [AccountModel]) {
        var coins = accountModels.map { $0.fullCurrencyName }
        
        // BTC 마켓 코인들을 위해 BTC 시세를 항상 확인함
        if !coins.contains("KRW-BTC") {
            coins.append("KRW-BTC")
        }
        
        quoteService.getCurrentPrice(markets: coins).subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let tickerModels):
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    MarketAll.shared.btcPrice = tickerModels.filter { $0.market == "KRW-BTC" }.first?.trade_price ?? 0.0
                    for accountModel in accountModels {
                        accountModel.quoteTickerModel = tickerModels.filter { $0.market == accountModel.fullCurrencyName }.first
                    }
                    let sortedAccoutModels = accountModels.sorted { $0.currentTotalPrice > $1.currentTotalPrice }
                    self?.accountModels = sortedAccoutModels
                    
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
}
