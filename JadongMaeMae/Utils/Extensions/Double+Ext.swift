//
//  Double+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/10.
//

import Foundation

extension Double {
    
    func numberForm(add: String) -> String {
        return String(format: "%.2f\(add)", self)
    }
    
    var rounded: Self { (self * 100) / 100 }
}
