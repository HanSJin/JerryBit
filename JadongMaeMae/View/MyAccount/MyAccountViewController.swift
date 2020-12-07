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
    @IBOutlet private weak var tableView: UITableView! {
        didSet { tableView.registerNib(cellIdentifier: MyAccountCell.identifier) }
    }
    
    // Variables
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private var disposeBag = DisposeBag()
    
    private var accountModels: [AccountModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
}

// MARK: - Setup View
extension MyAccountViewController {
    
    func setUpView() { }
}

// MARK: - GlobalRunLoop
extension MyAccountViewController: GlobalRunLoop {
    
    var fps: Double { 1 }
    func runLoop() { requestMyAccount() }
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

// MARK: - Request
extension MyAccountViewController {
    
    private func requestMyAccount() {
        accountsService.getMyAccounts().subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let result):
                self?.accountModels = result.fil
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }) { error in
            print(error)
        }.disposed(by: self.disposeBag)
    }
}

//        quoteService.getMinuteCandle(market: "KRW-BTC", unit: 1, count: 200).subscribe {
//            switch $0 {
//            case .success(let quoteModels):
//                print(quoteModels)
//            case .failure(let error):
//                print(error)
//            }
//        } onError: {
//            print($0)
//        }.disposed(by: disposeBag)
