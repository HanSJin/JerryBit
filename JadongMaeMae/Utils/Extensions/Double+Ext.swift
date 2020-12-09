//
//  Double+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/10.
//

import Foundation

extension Double {
    
    func numberForm(add: String) -> String {
        return String(format: "%.2f \(add)", self)
    }
}
