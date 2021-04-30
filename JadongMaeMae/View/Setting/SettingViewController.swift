//
//  SettingViewController.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2021/04/02.
//

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
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            guard let inputKey = alert.textFields?[0].text, !inputKey.isEmpty else { return }
            switch mode {
            case .accessKey: AppData.accessKey = inputKey
            case .secretKey: AppData.secretKey = inputKey
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addTextField { _ in }
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Setup View
extension SettingViewController {
    
    func setUpView() {
        title = "설정"
    }
    
    func updateCuteImage() {
        funnyImageView.image = UIImage(named: "cute\(Int.random(in: 0...12))")
    }
    
    func updateUpbitKeys() {
        if !AppData.accessKey.isEmpty {
            accessKeyTF.text = AppData.accessKey
        } else {
            accessKeyTF.text = "-"
        }
        if !AppData.secretKey.isEmpty {
            secretKeyTF.text = AppData.secretKey
        } else {
            secretKeyTF.text = "-"
        }
    }
}
