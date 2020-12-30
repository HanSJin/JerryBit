//
//  Double+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/10.
//

import Foundation

extension Double {
    
    func numberForm(add: String) -> String {
        return NumberFormatter.decimal(rounded) + add
    }
    
    var rounded: Double {
        (Double(Int64(self * 100.0)) / 100.0)
    }
}
