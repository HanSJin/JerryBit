//
//  TradeMachineViewController.swift
//  JadongMaeMae
//
//  Created by USER on 08/12/2020.
//

import UIKit
import RxSwift
import UIKit

class TradeMachineViewController: UIViewController {
    
    // Outlets
    
    // Variables
    private let quoteService: QuoteService = ServiceContainer.shared.getService(key: .quote)
    private let orderService: OrderService = ServiceContainer.shared.getService(key: .order)
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tappedBuyButton(_ sender: UIButton) {
        orderService.requestOrder(market: "KRW-EOS", side: "bid", volume: "1.0", price: "3120", ord_type: "limit", identifier: nil).subscribe(onSuccess: { [weak self] in
            switch $0 {
            case .success(let orderModels):
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

// MARK: - Setup View
extension TradeMachineViewController {
    
    func setUpView() {

    }
}

// MARK: - GlobalRunLoop
extension TradeMachineViewController: GlobalRunLoop {
    
    var fps: Double { 5 }
    func runLoop() {
        
    }
}

// MARK: - Request
extension TradeMachineViewController {

    private func getMinuteCandles() {
//        quoteService.getMinuteCandle(market: "KRW-ETH", unit: 1, count: 200).subscribe {
//            switch $0 {
//            case .success(let quoteModels):
//                print(quoteModels)
//            case .failure(let error):
//                guarerror.globalHandling()
//            }
//        } onError: {
//            prasdasdint($0)
//        }.disposed(by: disposeBag)
    }
}
