//
//  UserDefaultsManager.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/11.
//

import Foundation

final class UserDefaultsManager: UserDefaults {

    private enum Key {
        case tradeCoin
        case oncePrice
        case unit
        case maxCoinBuyAmmount
        
        var name: String {
            "\(Foundation.Bundle.main.bundleIdentifier ?? "").\(self)"
        }
    }
    
    // MARK: Internal

    static let shared = UserDefaultsManager()
    
    
    private func synchronizeAfterSet<T: Any>(_ value: T, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.name)
        UserDefaults.standard.synchronize()
    }
}

extension UserDefaultsManager {
    
    var tradeCoin: String? {
        get { UserDefaults.standard.string(forKey: Key.tradeCoin.name) }
        set { synchronizeAfterSet(newValue, forKey: .tradeCoin) }
    }
    var oncePrice: Int {
        get {
            if UserDefaults.standard.integer(forKey: Key.oncePrice.name) == 0 {
                return 5000
            }
            return UserDefaults.standard.integer(forKey: Key.oncePrice.name)
        }
        set { synchronizeAfterSet(newValue, forKey: .oncePrice) }
    }
    var unit: Int {
        get {
            if UserDefaults.standard.integer(forKey: Key.unit.name) == 0 {
                return 1
            }
            return UserDefaults.standard.integer(forKey: Key.unit.name)
        }
        set { synchronizeAfterSet(newValue, forKey: .unit) }
    }
    var maxCoinBuyAmmount: Int {
        get {
            if UserDefaults.standard.integer(forKey: Key.maxCoinBuyAmmount.name) == 0 {
                return oncePrice * 30
            }
            return UserDefaults.standard.integer(forKey: Key.maxCoinBuyAmmount.name)
        }
        set { synchronizeAfterSet(newValue, forKey: .maxCoinBuyAmmount) }
    }
}
