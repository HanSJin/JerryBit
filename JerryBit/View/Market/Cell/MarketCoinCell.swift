//
//  MarketCoinCell.swift
//  JerryBit
//
//  Created by SJin Han on 2021/05/05.
//

import UIKit

class MarketCoinCell: UITableViewCell {
    
    @IBOutlet private weak var coinNameLabel: UILabel!
    @IBOutlet private weak var coinCodeLabel: UILabel!
    @IBOutlet private weak var coinPercentLabel: UILabel!
    @IBOutlet private weak var coinPriceLabel: UILabel!
    @IBOutlet private weak var accPrice24HLabel: UILabel!
    
    var model: MarketModel! {
        didSet {
            modelDidUpdate()
        }
    }
    
    func modelDidUpdate() {
        guard let coinMarketInfo = model.coinMarketInfo, let quoteTickerModel = model.quoteTickerModel else { return }
        coinNameLabel.text = coinMarketInfo.korean_name
        coinCodeLabel.text = coinMarketInfo.market
        
        coinPriceLabel.text = quoteTickerModel.trade_price.numberForm(add: " KRW")
        
        switch quoteTickerModel.changeType {
        case .EVEN: coinPriceLabel.textColor = .black
        case .FALL: coinPriceLabel.textColor = UIColor.myBlue
        case .RISE: coinPriceLabel.textColor = UIColor.myRed
        }

        accPrice24HLabel.text = Double(Int(quoteTickerModel.acc_trade_price_24h / 1000_000)).numberForm(add: " 백만")
        
        coinPercentLabel.text = (quoteTickerModel.signed_change_rate * 100).numberForm(add: "%")
        if quoteTickerModel.signed_change_rate >= 0 {
            coinPercentLabel.textColor = .myRed
        } else {
            coinPercentLabel.textColor = .myBlue
        }
    }
}
