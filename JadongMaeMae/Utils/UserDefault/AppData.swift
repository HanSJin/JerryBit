//
//  AppData.swift
//  JadongMaeMae
//
//  Created by SJin Han on 2021/04/30.
//

import Foundation

struct AppData {
    
    @AppDataWrapper(key: "accessKey", default: "")
    static var accessKey: String
    
    @AppDataWrapper(key: "secretKey", default: "")
    static var secretKey: String
    
    static func clear() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
    }
}

@propertyWrapper
struct AppDataWrapper<Value> {
    let key: String
    let defaultValue: Value

    init(key: String, default value: Value) {
        self.key = key
        self.defaultValue = value
    }

    var wrappedValue: Value {
        get { UserDefaults.standard.value(forKey: key) as? Value ?? defaultValue }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
            print(newValue, key)
            UserDefaults.standard.synchronize()
        }
    }
}
