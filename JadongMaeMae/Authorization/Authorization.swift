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
    
    struct AuthKey {
        let accessKey: String
        let secretKey: String
    }
    
    func storedAuthKey() -> AuthKey {
        AuthKey(accessKey: AppData.accessKey, secretKey: AppData.secretKey)
    }
    
    func jwtToken(query: String?, verifyAuth: AuthKey?) -> String {
        let authKey = verifyAuth ?? storedAuthKey()
        
        let nonce = UUID().uuidString.lowercased()
        var queryHash = ""
        var queryHashAlg = ""
        
        if let query = query {
            queryHash = query.toSHA512String()
            queryHashAlg = "SHA512"
        }
        
        var claims = ClaimSet()
        claims["access_key"] = authKey.accessKey
        claims["nonce"] = nonce
        claims["query_hash"] = queryHash
        claims["query_hash_alg"] = queryHashAlg

        let signedJWT = JWT.encode(claims: claims, algorithm: .hs256(authKey.secretKey.data(using: .utf8)!))
        
        return "Bearer \(signedJWT)"
    }
}
