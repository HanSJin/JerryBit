//
//  AccountsService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

protocol AccountsService {
    func verifyAccess(authKey: Authorization.AuthKey) -> RestAPISingleResult<[AccountModel]>
    func getMyAccounts() -> RestAPISingleResult<[AccountModel]>
}

class AccountsServiceImp: AccountsService {
    
    func verifyAccess(authKey: Authorization.AuthKey) -> RestAPISingleResult<[AccountModel]> {
        let path = "/v1/accounts"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:], needAuth: true)
            .set(authKey: authKey)
            .build()
        return RestAPIClient.shared.request(request: request, type: [AccountModel].self)
    }
    
    func getMyAccounts() -> RestAPISingleResult<[AccountModel]> {
        let path = "/v1/accounts"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:], needAuth: true).build()
        return RestAPIClient.shared.request(request: request, type: [AccountModel].self)
    }
}
