//
//  OrderService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation


protocol OrderService {
    func requestBuy(market: String, price: String) -> RestAPISingleResult<OrderModel>
    func requestSell(market: String, volume: String) -> RestAPISingleResult<OrderModel>
    
    // 주문 내역
    func reuqestOrders(market: String, states: String, kind: String, page: Int, limit: Int) -> RestAPISingleResult<[OrderModel]>
}

class OrderServiceImp: OrderService {

    func requestBuy(market: String, price: String) -> RestAPISingleResult<OrderModel> {
        requestOrder(market: market, side: "bid", volume: "", price: price, ord_type: "price")
    }
    
    func requestSell(market: String, volume: String) -> RestAPISingleResult<OrderModel> {
        requestOrder(market: market, side: "ask", volume: volume, price: "", ord_type: "market")
    }
    
    /// https://docs.upbit.com/reference#주문하기
    private func requestOrder(market: String, side: String, volume: String, price: String, ord_type: String, identifier: String? = nil) -> RestAPISingleResult<OrderModel> {
        let path = "/v1/orders"
        let request = RestAPIClientBuilder(path: path, method: .post, headers: [:], needAuth: true)
            .set(httpBody: [
                "market": market,
                "side": side,
                "volume": volume,
                "price": price,
                "ord_type": ord_type
            ]).build()
        return RestAPIClient.shared.request(request: request, type: OrderModel.self)
    }
    
    func reuqestOrders(market: String, states: String, kind: String, page: Int, limit: Int) -> RestAPISingleResult<[OrderModel]> {
        let path = "/v1/orders"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:], needAuth: true)
            .set(queryName: "market", queryValue: market)
            .set(queryName: "state", queryValue: "done")
//            .set(queryName: "uuids[]", queryValue: "11ba8831-c058-4616-8622-53cb6aa84254")
            .build()
        return RestAPIClient.shared.request(request: request, type: [OrderModel].self)
        
        
//        let path = "/v1/orders"
//        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:], needAuth: true)
//            .set(queryName: "market", queryValue: market)
//            .set(queryName: "state", queryValue: "done")
//            .set(queryName: "kind", queryValue: "normal")
//            .set(queryName: "uuids[]", queryValue: "9ca023a5-851b-4fec-9f0a-48cd83c2eaae")
//            .set(queryName: "page", queryValue: "\(page)")
//            .set(queryName: "limit", queryValue: "\(limit)")
//            .build()
//        return RestAPIClient.shared.request(request: request, type: [OrderModel].self)
    }
}
