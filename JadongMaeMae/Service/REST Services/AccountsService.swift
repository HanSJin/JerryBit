//
//  AccountsService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

// MARK: - AppStoreLookUpService

protocol AccountsService {
    func getMyAccounts() -> RestAPISingleResult<[AccountModel]>
}

// MARK: - AppStoreLookUpServiceImp

class AccountsServiceImp: AccountsService {

    func getMyAccounts() -> RestAPISingleResult<[AccountModel]> {
        let path = "/accounts"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:]).build()
        return RestAPIClient.shared.request(request: request, type: [AccountModel].self)
    }
}
