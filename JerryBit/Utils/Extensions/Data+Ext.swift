//
//  Data+Ext.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation

// MARK: - For SHA512
extension Data {

    func toSHA512String() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        withUnsafeBytes({
            _ = CC_SHA512($0, CC_LONG(self.count), &digest)
        })
        return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
}
