//
//  Authorization.swift
//  JadongMaeMae
//
//  Created by USER on 2020/12/07.
//

import Foundation
import JWT
//import SwiftJWT

//struct MyClaims: Claims {
//    let access_key: String
//    let nonce: String
//    let query_hash: String
//    let query_hash_alg: String
//}

class Authorization {
    
    static let shared = Authorization()
    
    func jwtToken(query: String?) -> String {
        guard let accessKey = FileController().readFile(name: "accessKey"),
              let secretKey = FileController().readFile(name: "secretKey") else {
            fatalError("'accessKey' and 'secretKey' file is required in proj root.")
        }
        
        let nonce = UUID().uuidString.lowercased()
        var queryHash = ""
        var queryHashAlg = ""
        
        if let query = query {
            queryHash = query.toSHA512String()
            queryHashAlg = "SHA512"
        }
        
        var claims = ClaimSet()
        claims["access_key"] = accessKey
        claims["nonce"] = nonce
        claims["query_hash"] = queryHash
        claims["query_hash_alg"] = queryHashAlg

        let signedJWT = JWT.encode(claims: claims, algorithm: .hs256(secretKey.data(using: .utf8)!))
        
        /*
        let myClaims = MyClaims(access_key: accessKey, nonce: nonce, query_hash: queryHash, query_hash_alg: queryHashAlg)
        var myJWT = JWT(claims: myClaims)
        let jwtSigner = JWTSigner.hs256(key: secretKey.data(using: .utf8)!)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        print(signedJWT)
        */
        return "Bearer \(signedJWT)"
    }
}

/*
do {
  let claims: ClaimSet = try JWT.decode(jwtToken, algorithm: .hs256(secretKey.data(using: .utf8)!))
  print(claims)
} catch {
  print("Failed to decode JWT: \(error)")
}
 */
