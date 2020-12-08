//
//  Error+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import UIKit

extension Error {
    
    func handle() {
        print(self)
        
        if let responseError = self as? RestAPIClient.ResponseError, case .serverMessage(let errorModel) = responseError {
            UIAlertController.simpleAlert(message: errorModel.error.message + "\ncode: " + errorModel.error.name)
        }
    }
}
