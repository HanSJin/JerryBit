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
    
    func updateView(_ accountModel: AccountModel) {
        coinNameLabel.text = accountModel.currency
        balanceLabel.text = accountModel.balance
        coinUnitLabel.text = accountModel.currency
        avgPriceLabel.text = accountModel.avg_buy_price
        currencyLabel.text = accountModel.unit_currency
        
        guard let quoteTickerModel = accountModel.quoteTickerModel else { return }
        currentPriceLabel.text = "\(Int(quoteTickerModel.trade_price ?? 0)) KRW"
        
        switch quoteTickerModel.changeType {
        case .EVEN: currentPriceLabel.textColor = .black
        case .FALL: currentPriceLabel.textColor = UIColor.myBlue
        case .RISE: currentPriceLabel.textColor = UIColor.myRed
        }
        
        currentAmountLabel.text = "\(NumberFormatter.decimalFormat(Int(accountModel.currentTotalPrice))) KRW"
        
        if let avg_buy_price = Double(accountModel.avg_buy_price ?? "0"), let trade_price = quoteTickerModel.trade_price {
            currentPercentLabel.text = String(format: "%.2f", ((trade_price / avg_buy_price) - 1) * 100) + " %"
            
            if avg_buy_price < trade_price {
                currentPercentLabel.textColor = UIColor.myRed
                currentAmountLabel.textColor = UIColor.myRed
            } else {
                currentPercentLabel.textColor = UIColor.myBlue
                currentAmountLabel.textColor = UIColor.myBlue
            }
        } else {
            currentPercentLabel.textColor = .black
            currentAmountLabel.textColor = .black
        }
    }
}
