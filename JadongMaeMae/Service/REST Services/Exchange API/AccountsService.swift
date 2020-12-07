//
//  AccountsService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

protocol AccountsService {
    func getMyAccounts() -> RestAPISingleResult<[AccountModel]>
}

class AccountsServiceImp: AccountsService {

    func getMyAccounts() -> RestAPISingleResult<[AccountModel]> {
        let path = "/v1/accounts"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:], needAuth: true).build()
        return RestAPIClient.shared.request(request: request, type: [AccountModel].self)
    }
}
