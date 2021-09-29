//
//  Dictionary+Ext.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key, value) in self {
            output += "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }

    static func + (lhs: [Dictionary.Key: Dictionary.Value], rhs: [Dictionary.Key: Dictionary.Value]) -> [Dictionary.Key: Dictionary.Value] {
        lhs.merging(rhs)
    }

    func merging(_ other: [Dictionary.Key: Dictionary.Value]) -> [Dictionary.Key: Dictionary.Value] {
        merging(other) { first, _ in first }
    }
}
