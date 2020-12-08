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
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
//                print(error)
//            }
//        } onError: {
//            print($0)
//        }.disposed(by: disposeBag)
    }
}
