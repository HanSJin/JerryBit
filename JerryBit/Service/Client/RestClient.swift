//
//  RestClient.swift
//  JerryBit
//
//  Created by HanSJin on 2020/12/07.
//

import Alamofire
import Foundation
import RxSwift

typealias RestAPISingleResult<Response> = Single<Swift.Result<Response, RestAPIClient.ResponseError>>

// MARK: - ResponseError

extension RestAPIClient {

    enum ResponseError: Error {
        case requestError(Error)
        case decodeError(Error)
        case serverMessage(ErrorModel)
    }
}

// MARK: - RestAPIClient

class RestAPIClient {

    // MARK: Internal

    static let shared: RestAPIClient = {
        RestAPIClient()
    }()

    func request<Response: Decodable>(
        request: URLRequest,
        type: Response.Type) -> RestAPISingleResult<Response>
    {
        print("🚀 [RestAPI Request]", request.httpMethod!, request.url!, "/ Response:", Response.self)
        if let method = request.httpMethod, method == "POST", let body = request.httpBody {
            print("🚀 [RestAPI Request Body]", String(data: body, encoding: .utf8) ?? "")
        }

        return self.request(request: request, type: Response.self, responseTransform: { data -> Swift.Result<Response, ResponseError> in
            do {
                let decode = JSONDecoder()
                if #available(iOS 10.0, *) {
                    decode.dateDecodingStrategy = .iso8601
                } else {
                    // Fallback on earlier versions
                }
                let decodedResponse = try decode.decode(Response.self, from: data) as Response
                return .success(decodedResponse)
            } catch let error {
                return .failure(ResponseError.decodeError(error))
            }
        }).retry(2)
    }

    // MARK: Private

    private func request<Response>(
        request: URLRequest,
        type: Response.Type,
        responseTransform: @escaping (Data) -> Swift.Result<Response, ResponseError>) -> RestAPISingleResult<Response>
    {
        Single.create(subscribe: { singleEvent -> Disposable in
            Alamofire.request(request)
                .validate(statusCode: 200 ..< 300)
                .responseData(completionHandler: { response in

                    let responseString = String(data: response.data!, encoding: .utf8) ?? "?"

                    switch response.map(responseTransform).result {
                    case Alamofire.Result.success(let successResult):
                        print("✅ [RestAPI Response]", response.response?.statusCode ?? "-1")//, "\(responseString)", "\n")
                        return singleEvent(.success(successResult))
                    case Alamofire.Result.failure(let error):
                        print("🆘 [RestAPI Response]", response.response?.statusCode ?? "-1", "\(String(describing: request.url?.absoluteString ?? ""))\n", "\(responseString)", "\n")
                        
                        if let decodedError = try? JSONDecoder().decode(ErrorModel.self, from: response.data!) as ErrorModel {
                            return singleEvent(.success(.failure(ResponseError.serverMessage(decodedError))))
                        } else {
                            return singleEvent(.success(.failure(ResponseError.requestError(error))))
                        }
                    }
                }
            )
            return Disposables.create()
        })
    }
}
