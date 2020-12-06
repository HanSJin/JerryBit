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
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
}

extension MainViewController {
    
    func setUpView() {
        testButton.rx.tap
            .bind { [unowned self] in self.requestMyAccount() }
            .disposed(by: disposeBag)
    }
}

extension MainViewController {
    
    private func requestMyAccount() {
        /*
        self.requestMyAccounts2()
            .catchError { _ in
                return .empty()
            }
            .bind { [unowned self] in
            
            }
            .disposed(by: disposeBag)
         */
        self.accountsService.getMyAccounts()
            .do(onSubscribe: {
                
            }, onDispose: {
                
            })
            .subscribe(onSuccess: { response in
                switch response {
                case .success(let result):
                    print(result)
                case .failure(let error):
                    print(error)
                }
        }) { error in
            print(error)
        }.disposed(by: disposeBag)
    }
    
    private func requestMyAccounts2() -> Observable<Void> {
        return Observable<Void>.create { [unowned self] observer in
            let disposable = Disposables.create()
            self.accountsService.getMyAccounts()
                .do(onSubscribe: {
                    
                }, onDispose: {
                    
                })
                .subscribe(onSuccess: { response in
                    switch response {
                    case .success(let result):
                        print(result)
                    case .failure(let error):
                        print(error)
                        observer.onError(error)
                    }
            }) { error in
                print(error)
                observer.onError(error)
            }.disposed(by: self.disposeBag)
            return disposable
        }
    }
}
