//
//  GetMyAccountsResponse.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import Foundation

//struct GetMyAccountsResponse: Decodable {
//
//    private enum CodingKeys: String, CodingKey {
//        case results
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let results = try container.decodeIfPresent([AppStoreLookUpResult].self, forKey: .results)
//        self.init(results: results)
//    }
//    init(results: [AppStoreLookUpResult]?) {
//        self.results = results
//    }
//
//    // MARK: Internal
//
//    struct AppStoreLookUpResult: Decodable {
//        private enum CodingKeys: String, CodingKey {
//            case version
//        }
//
//        let version: String?
//
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let version = try container.decodeIfPresent(String.self, forKey: .version)
//            self.init(version: version)
//        }
//        init(version: String?) {
//            self.version = version
//        }
//    }
//
//    let results: [AppStoreLookUpResult]?
//
//}
