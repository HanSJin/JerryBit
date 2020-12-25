//
//  TradeOrderCell.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/20.
//

import UIKit

class TradeOrderCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sideLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel! // 총 주문 가격
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // Variables
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

// MARK: - Update View
extension TradeOrderCell {
    
    func updateView(_ order: OrderModel) {
        dateLabel.text = order.created_at.toStringWithDefaultFormat(to: "yy/MM/dd HH:mm:ss")
        sideLabel.text = order.sideValue
        sideLabel.textColor = order.sideColor
        stateLabel.text = "(" + order.stateValue + ")"
        volumeLabel.text = order.volume
        if order.ord_type == "limit" {
            priceLabel.text = order.price
        } else {
            priceLabel.text = "시장가"
        }
        amountLabel.text = order.amountValue.numberForm(add: " KRW")
    }
}
