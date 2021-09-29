//
//  Error+Ext.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/09.
//

import UIKit

extension Error {
    
    func globalHandling() -> Bool {
        print(self)
        
        if let responseError = self as? RestAPIClient.ResponseError, case .serverMessage(let errorModel) = responseError {
            UIAlertController.simpleAlert(message: errorModel.error.message + "\ncode: " + errorModel.error.name)
            
            if errorModel.error.name == "invalid_access_key" {
                GlobalTimer.enable = false
            }
            return true
        }
        return false
    }
}
