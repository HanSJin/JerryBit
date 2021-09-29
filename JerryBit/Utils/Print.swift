//
//  Print.swift
//  JerryBit
//
//  Created by USER on 2020/12/07.
//

import Foundation

public func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let item = items
        .map { String(describing: $0) }
        .joined(separator: separator)
    Swift.debugPrint(" 🕸 \(item)", terminator: terminator)
}

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let item = items
        .map { String(describing: $0) }
        .joined(separator: separator)
    Swift.print(" 🕸 \(item)", terminator: terminator)
}
