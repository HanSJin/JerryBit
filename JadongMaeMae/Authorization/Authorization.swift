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
    var jwtToken: String?
    
    var hasAccessToken: Bool {
        jwtToken?.isEmpty ?? false
    }
    var accessToken: String {
        "Bearer \(jwtToken ?? "")"
    }
    
    func auth() {
        guard let accessKey = FileController().readFile(name: "accessKey"),
              let secretKey = FileController().readFile(name: "secretKey") else {
            fatalError("'accessKey' and 'secretKey' file is required in proj root.")
        }
        
        let nonce = UUID().uuidString
        
        let claims = [ "access_key": accessKey, "nonce": nonce ]
        let token = JWT.encode(claims: claims, algorithm: .hs256(secretKey.data(using: .utf8)!))
        jwtToken = token
        print("token:", token)
        print(printIpAddress())
    }
    
    private func printIpAddress() {
        guard let url = URL(string: "https://api.ipify.org") else { return }
        let ipAddress = try? String(contentsOf: url)
        print("My public IP address is: " + (ipAddress ?? "Unknown"))
    }
}
