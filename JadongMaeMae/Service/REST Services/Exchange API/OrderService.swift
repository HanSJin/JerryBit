//
//  OrderService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation


protocol OrderService {
    func requestBuy(market: String, price: String) -> RestAPISingleResult<[OrderModel]>
    func requestSell(market: String, volume: String) -> RestAPISingleResult<[OrderModel]>
}

class OrderServiceImp: OrderService {

    func requestBuy(market: String, price: String) -> RestAPISingleResult<[OrderModel]> {
        requestOrder(market: market, side: "bid", volume: "", price: price, ord_type: "price")
    }
    
    func requestSell(market: String, volume: String) -> RestAPISingleResult<[OrderModel]> {
        requestOrder(market: market, side: "ask", volume: volume, price: "", ord_type: "market")
    }
    
    /// https://docs.upbit.com/reference#주문하기
    private func requestOrder(market: String, side: String, volume: String, price: String, ord_type: String, identifier: String? = nil) -> RestAPISingleResult<[OrderModel]> {
        let path = "/v1/orders"
        let request = RestAPIClientBuilder(path: path, method: .post, headers: [:], needAuth: true)
            .set(httpBody: [
                "market": market,
                "side": side,
                "volume": volume,
                "price": price,
                "ord_type": ord_type
            ])
            .build()
        return RestAPIClient.shared.request(request: request, type: [OrderModel].self)
    }
}
