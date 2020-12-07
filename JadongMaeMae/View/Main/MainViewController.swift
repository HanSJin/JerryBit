//
//  ViewController.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import RxCocoa
import RxSwift
import UIKit

class MainViewController: UIViewController {

    // Outelts
    @IBOutlet weak var testButton: UIButton!
    
    // Variables
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
}

extension MainViewController {
    
    func setUpView() {
//        testButton.rx.tap
//            .bind { [unowned self] in self.requestMyAccount() }
//            .disposed(by: disposeBag)
    }
}

extension MainViewController: GlobalRunLoop {
    
    var fps: Double { 1 }
    
    func runLoop() {
        requestMyAccount()
    }
}

extension MainViewController {
    
    private func requestMyAccount() {
//        accountsService.getMyAccounts()
//            .subscribe(onSuccess: { response in
//                switch response {
//                case .success(let result):
//                    print(result)
//                case .failure(let error):
//                    print(error)
//                }
//        }) { error in
//            print(error)
//        }.disposed(by: self.disposeBag)
        
        quoteService.getMinuteCandle(market: "KRW-BTC", unit: 1, count: 200).subscribe {
            switch $0 {
            case .success(let quoteModels):
                print(quoteModels)
            case .failure(let error):
                print(error)
            }
        } onError: {
            print($0)
        }.disposed(by: disposeBag)
    }
}
