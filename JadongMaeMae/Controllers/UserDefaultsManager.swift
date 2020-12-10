//
//  UserDefaultsManager.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/11.
//

import Foundation

final class UserDefaultsManager: UserDefaults {

    private enum Key {
        case tradeCoin
        
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
}
