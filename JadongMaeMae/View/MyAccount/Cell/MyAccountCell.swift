//
//  MyAccountCell.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

class MyAccountCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var currentPercentLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var coinUnitLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    // Variables
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

// MARK: - Update View
extension MyAccountCell {
    
    func updateView(_ account: AccountModel) {
        var krName = account.coinMarketInfo?.korean_name ?? ""
        if krName.count > 3 {
            let endIdx: String.Index = krName.index(krName.startIndex, offsetBy: 3)
            krName = String(krName[...endIdx])
        }
        coinNameLabel.text = krName + " " + account.currency
        balanceLabel.text = "보유 \(account.balanceDouble + account.lockedDouble)"
        coinUnitLabel.text = account.currency
        avgPriceLabel.text = "평단 \(NumberFormatter.decimal(account.avgBuyPriceDouble)) \(account.unitCurrencyString)"
        currencyLabel.text = account.unit_currency
        
        guard let quoteTickerModel = account.quoteTickerModel else { return }
        
        currentPriceLabel.text = "(현재 " + quoteTickerModel.trade_price.numberForm(add: ")")
        
        switch quoteTickerModel.changeType {
        case .EVEN: currentPriceLabel.textColor = .black
        case .FALL: currentPriceLabel.textColor = UIColor.myBlue
        case .RISE: currentPriceLabel.textColor = UIColor.myRed
        }
        
        currentAmountLabel.text = "\(NumberFormatter.decimal(Int(account.currentTotalPrice)))"
        
        let revenueRate = ((account.tradePrice / account.avgBuyPriceDouble) - 1)
        currentPercentLabel.text = String(format: "%.2f", revenueRate * 100) + "%"
        let sign = account.tradePrice > account.avgBuyPriceDouble ? "+" : ""
        let revenue = (account.tradePrice - account.avgBuyPriceDouble) * (account.balanceDouble + account.lockedDouble)
        revenueLabel.text = sign + "\(NumberFormatter.decimal(Int(revenue))) \(account.unitCurrencyString)"
        
        if account.avgBuyPriceDouble < account.tradePrice {
            currentPercentLabel.textColor = UIColor.myRed
            revenueLabel.textColor = UIColor.myRed
        } else if account.avgBuyPriceDouble == account.tradePrice {
            currentPercentLabel.textColor = UIColor.myBlue
            revenueLabel.textColor = UIColor.myBlue
        } else {
            currentPercentLabel.textColor = UIColor.myBlue
            revenueLabel.textColor = UIColor.myBlue
        }
    }
}
