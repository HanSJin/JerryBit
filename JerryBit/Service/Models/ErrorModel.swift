//
//  ErrorModel.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation

struct ErrorModel: Decodable {
    let error: ErrorDefinition
    
    struct ErrorDefinition: Decodable {
        let message: String
        let name: String
    }
}
