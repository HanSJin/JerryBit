//
//  String+Ext.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

// MARK: - For SHA256

extension String {

    // MARK: Internal

    func toSHA256Data() -> NSData? {
        guard let stringData = data(using: String.Encoding.utf8) else {
            return nil
        }
        return digest(input: stringData as NSData)
    }

    // MARK: Private

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
}

// MARK: - For SHA512
extension String {

    func toSHA512String() -> String {
        let data = self.data(using: .utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        data.withUnsafeBytes({
            _ = CC_SHA512($0, CC_LONG(data.count), &digest)
        })
        return digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
    }
}
