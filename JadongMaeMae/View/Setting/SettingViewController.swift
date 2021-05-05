//
//  SettingViewController.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2021/04/02.
//

import RxCocoa
import RxSwift
import UIKit

enum InputMode {
    case accessKey, secretKey
    var inputDescription: String {
        switch self {
        case .accessKey: return "AccessKey를 붙여 넣어주세요~~~~~"
        case .secretKey: return "SecretKey를 붙여 넣어주세요~~~~~"
        }
    }
}
class SettingViewController: BaseViewController {

    // Outlets
    @IBOutlet weak var funnyImageView: UIImageView!
    @IBOutlet weak var upbitLinkButton: UIButton!
    @IBOutlet weak var accessKeyTF: UILabel!
    @IBOutlet weak var secretKeyTF: UILabel!
    @IBOutlet weak var verifyButton: UIButton! {
        didSet {
            verifyButton.layer.cornerRadius = 10
            verifyButton.layer.borderWidth = 1
            verifyButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    @IBOutlet weak var clearVerifyButton: UIButton! {
        didSet {
            clearVerifyButton.layer.cornerRadius = 10
            clearVerifyButton.layer.borderWidth = 1
            clearVerifyButton.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    
    // Variables
    private let accountsService: AccountsService = ServiceContainer.shared.getService(key: .accounts)
    private var disposeBag = DisposeBag()
    
    private var accessKey: String?
    private var secretKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCuteImage()
        updateUpbitKeys()
    }
    
    @IBAction func tappedIPButton(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let url = URL(string: "https://api.ipify.org") else { return }
            let ipAddress = try? String(contentsOf: url)
            DispatchQueue.main.async {
                UIAlertController.simpleAlert(message: "IP Addr: " + (ipAddress ?? "Unknown"), autoClose: false)
            }
        }
    }
}

// MARK: UI Touch Events
extension SettingViewController {
    
    @IBAction func tappedUpbitLinkButton(_ sender: UIButton) {
        guard let url = URL(string: "https://www.upbit.com/service_center/open_api_guide") else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    @IBAction func tappedInsertAccessKey(_ sender: UIButton) {
        inputTextAlert(mode: .accessKey)
    }
    
    @IBAction func tappedInsertSecureKey(_ sender: UIButton) {
        inputTextAlert(mode: .secretKey)
    }
    
    private func inputTextAlert(mode: InputMode) {
        let alert = UIAlertController(title: nil, message: mode.inputDescription, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let inputKey = alert.textFields?[0].text, !inputKey.isEmpty else { return }
            switch mode {
            case .accessKey: self?.accessKey = inputKey
            case .secretKey: self?.secretKey = inputKey
            }
            self?.updateUpbitKeys()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addTextField { _ in }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tappedVerifyButton(_ sender: UIButton) {
        let accessKey = self.accessKey ?? AppData.accessKey
        let secretKey = self.secretKey ?? AppData.secretKey
        
        guard accessKey != "" else {
            UIAlertController.simpleAlert(message: "저장된 AccessKey 가 없습니다.")
            return
        }
        guard secretKey != "" else {
            UIAlertController.simpleAlert(message: "저장된 SecretKey 가 없습니다.")
            return
        }
        AppData.accessKey = accessKey
        AppData.secretKey = secretKey
        
        requestVerifyAccess(authKey: .init(accessKey: accessKey, secretKey: secretKey)) { [weak self] result in
            GlobalTimer.enable = true
            
            if result {
                UIAlertController.simpleAlert(message: "Verified!")
                self?.clearAuthInInstance()
            }
        }
    }
    
    @IBAction func tappedClearVerifyButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "계정 정보를 진짜 삭제해요?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            AppData.clear()
            self?.clearAuthInInstance()
            self?.updateUpbitKeys()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Setup View
extension SettingViewController {
    
    private func setUpView() {
        title = "설정"
    }
    
    private func updateCuteImage() {
        funnyImageView.image = UIImage(named: "cute\(Int.random(in: 0...12))")
    }
    
    private func updateUpbitKeys() {
        let accessKey = self.accessKey ?? AppData.accessKey
        if !accessKey.isEmpty {
            accessKeyTF.text = accessKey
        } else {
            accessKeyTF.text = "-"
        }
        
        let secretKey = self.secretKey ?? AppData.secretKey
        if !secretKey.isEmpty {
            secretKeyTF.text = secretKey
        } else {
            secretKeyTF.text = "-"
        }
    }
    
    private func clearAuthInInstance() {
        accessKey = nil
        secretKey = nil
    }
}

// MARK: - Request
extension SettingViewController {
    
    private func requestVerifyAccess(authKey: Authorization.AuthKey, completion: @escaping (Bool) -> Void) {
        accountsService.verifyAccess(authKey: authKey).subscribe(onSuccess: {
            switch $0 {
            case .success:
                completion(true)
            case .failure(let error):
                error.globalHandling()
                completion(false)
                // Addtional Handling
            }
        }) { error in
            error.globalHandling()
            completion(false)
            // Addtional Handling
        }.disposed(by: self.disposeBag)
    }
}
