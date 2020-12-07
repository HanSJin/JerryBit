//
//  Authorization.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import Foundation
import JWT

class Authorization {
    
    static let shared = Authorization()
    
    func jwtToken(query: String?) -> String {
        guard let accessKey = FileController().readFile(name: "accessKey"),
              let secretKey = FileController().readFile(name: "secretKey") else {
            fatalError("'accessKey' and 'secretKey' file is required in proj root.")
        }
        
        let nonce = UUID().uuidString
        
        var claims = [ "access_key": accessKey, "nonce": nonce ]
        if let queryString = query {
            
            claims["query_hash"] = queryString.toSHA512String()
            claims["query_hash_alg"] = "SHA512"
        }
        let jwtToken = JWT.encode(claims: claims, algorithm: .hs256(secretKey.data(using: .utf8)!))
        print("Bearer", jwtToken)
        return "Bearer \(jwtToken)"
    }
}
