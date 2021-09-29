//
//  RestAPIClientBuilder.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import Alamofire
import Foundation

extension RestAPIClientBuilder {

    enum HeaderType {
        case json
        case form
        case textPlain
        case binary
    }
}

// MARK: - RestAPIClientBuilder

class RestAPIClientBuilder {

    private let endPoint = "https://api.upbit.com"
    private let path: String
    private let method: HTTPMethod
    private var headers: HTTPHeaders?
    private var queryItems = [URLQueryItem]()
    private var httpBody: Data?
    private var httpBodyParameters = [String: Any]()
    private let needAuth: Bool
    
    // AccessKey, SecretKey 유효성 검증
    private var verifyAuthKey: Authorization.AuthKey?
    
    // MARK: Lifecycle

    init(/*endPoint: String, */path: String, method: HTTPMethod, headers: HTTPHeaders? = nil, needAuth: Bool = false) {
        // self.endPoint = endPoint
        self.path = path
        self.method = method
        self.headers = headers
        self.needAuth = needAuth
    }

    // MARK: Internal

    func set(httpBody body: Data) -> Self {
        httpBody = body
        return self
    }

    func set(httpBody parameters: [String: Any]) -> Self {
        httpBodyParameters = parameters
        httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        return self
    }

    func sethttpBodyWithoutJSON(httpBody parameters: [String: Any]) -> Self {
        let httpBodyString = parameters.queryString
        httpBody = httpBodyString.data(using: .utf8)
        return self
    }

    func set(httpBody parameters: [String]) -> Self {
        httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        return self
    }

    func set(httpBody body: String) -> Self {
        httpBody = body.data(using: .utf8)
        return self
    }

    func set(queryName: String, queryValue: String) -> Self {
        queryItems.append(URLQueryItem(name: queryName, value: queryValue))
        return self
    }
    
    func set(authKey: Authorization.AuthKey) -> Self {
        self.verifyAuthKey = authKey
        return self
    }

    func build(headerType: HeaderType = .json) -> URLRequest {
        var defaultHeaders: [String: String] = [:]
        
        if needAuth {
            if !queryItems.isEmpty {
                let queryString = queryItems.map { "\($0.name)=\($0.value!)" }.joined(separator: "&")
                defaultHeaders["Authorization"] = Authorization.shared.jwtToken(query: queryString, verifyAuth: verifyAuthKey)
            } else if !httpBodyParameters.isEmpty {
                defaultHeaders["Authorization"] = Authorization.shared.jwtToken(query: httpBodyParameters.queryString, verifyAuth: verifyAuthKey)
            } else {
                defaultHeaders["Authorization"] = Authorization.shared.jwtToken(query: nil, verifyAuth: verifyAuthKey)
            }
        }
        
        let url = URL(string: endPoint)!.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        var header: HTTPHeaders = headers ?? [:]

        switch headerType {
        case .json:
            header["Content-Type"] = "application/json; charset=utf-8"
        case .form:
            header["Content-Type"] = "application/x-www-form-urlencoded"
        case .textPlain:
            header["Content-Type"] = "text/plain"
        case .binary:
            header["Content-Type"] = "image/jpeg"
        }

        var request: URLRequest = try! URLRequest(url: components.url!, method: method, headers: header + defaultHeaders)
        request.httpBody = httpBody
        return request
    }
}
