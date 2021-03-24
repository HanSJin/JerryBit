//
//  MyAccountViewController.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import RxCocoa
import RxSwift
import UIKit

class MyAccountViewController: UIViewController {

    // Outelts
    @IBOutlet private weak var settingBarButton: UIBarButtonItem!
    @IBOutlet private weak var tableView: UITableView! {
        didSet { tableView.registerNib(cellIdentifier: MyAccountCell.identifier) }
    }
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var totalAccount: UILabel!
    @IBOutlet weak var krwBalanceLabel: UILabel!
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
    
    private var excludedCoins: [String] = ["KRW", "PTOY", "PSG", "JUV", "FIL", "PICA"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
}

// MARK: - Setup View
extension MyAccountViewController {
    
    func setUpView() {
        navigationItem.title = "내 계좌"
        updateIpAddress()
        tradeNameTF.text = UserDefaultsManager.shared.tradeCoin
        requestMyAccount { [weak self] accountModels in
            self?.requestCurrentPrice(accountModels: accountModels)
        }
    }
    
    private func updateIpAddress() {
        guard let url = URL(string: "https://api.ipify.org") else { return }
        let ipAddress = try? String(contentsOf: url)
        ipLabel.text = ipAddress
        print("My public IP address is: " + (ipAddress ?? "Unknown"))
    }
}

// MARK: - GlobalRunLoop
extension MyAccountViewController: GlobalRunLoop {
    
    var fps: Double { 3 }
    func runLoop() {
        requestMyAccount { [weak self] accountModels in
            self?.requestCurrentPrice(accountModels: accountModels)
        }
        totalAccount.text = NumberFormatter.decimal(Int(accountModels.map { $0.currentTotalPrice }.reduce(0.0) { Double($0) + Double($1) })) + " KRW"
        krwBalanceLabel.text = String(format: "%.2f KRW", krwAccountModel?.balanceDouble ?? 0)
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
        moveToTradeMachine(currency: currency)
    }
    
    private func moveToTradeMachine(currency: String) {
        UserDefaultsManager.shared.tradeCoin = currency
        let tradeMachineVC = UIStoryboard(name: "TradeMachine", bundle: nil).instantiateInitialViewController() as! TradeMachineViewController
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
    
    private func requestMyAccount(completion: @escaping ([AccountModel]) -> Void) {
        accountsService.getMyAccounts().subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let accountModels):
                self?.krwAccountModel = accountModels.filter { $0.currency == "KRW" }.first
                let filteredAccountModels = accountModels.filter { [weak self] accountModel -> Bool in
                    return !(self?.excludedCoins.contains(accountModel.currency) ?? true)
                }
                completion(filteredAccountModels)
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
        quoteService.getCurrentPrice(markets: accountModels.map { "KRW-\($0.currency)" }).subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let tickerModels):
                for accountModel in accountModels {
                    accountModel.quoteTickerModel = tickerModels.filter { $0.market == "KRW-\(accountModel.currency)" }.first
                }
                let sortedAccoutModels = accountModels.sorted { $0.currentTotalPrice > $1.currentTotalPrice }
                self?.accountModels = sortedAccoutModels
                self?.tableView.reloadData()
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
