//
//  OrderService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation


protocol OrderService {
    func requestOrder(market: String, side: String, volume: String, price: String, identifier: String?) -> RestAPISingleResult<[OrderModel]>
}

class OrderServiceImp: OrderService {

    /// https://docs.upbit.com/reference#주문하기
    func requestOrder(market: String, side: String, volume: String, price: String, identifier: String? = nil) -> RestAPISingleResult<[OrderModel]> {
        let path = "/v1/orders"
        let request = RestAPIClientBuilder(path: path, method: .post, headers: [:], needAuth: true)
            .set(httpBody: [
                "market": market,
                "side": side,
                "volume": volume,
                "price": price
            ])
            .build()
        return RestAPIClient.shared.request(request: request, type: [OrderModel].self)
    }
}
