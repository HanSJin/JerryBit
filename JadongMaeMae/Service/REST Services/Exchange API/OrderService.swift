//
//  OrderService.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation


protocol OrderService {
    func requestBuy(market: String, volume: String, price: String) -> RestAPISingleResult<OrderModel>
    func requestSell(market: String, volume: String, price: String) -> RestAPISingleResult<OrderModel>
    
    // 주문 내역
    func requestOrders(market: String, page: Int, limit: Int) -> RestAPISingleResult<[OrderModel]>
    
    // 주문 취소
    func requestCancelOrder(uuid: String) -> RestAPISingleResult<OrderModel>
}

class OrderServiceImp: OrderService {

    enum OrderError: Error {
        case largePrice
    }
    
    func requestBuy(market: String, volume: String, price: String) -> RestAPISingleResult<OrderModel> {
        requestOrder(market: market, side: "bid", volume: volume, price: price, ord_type: "limit")
    }
    
    func requestSell(market: String, volume: String, price: String) -> RestAPISingleResult<OrderModel> {
        requestOrder(market: market, side: "ask", volume: volume, price: price, ord_type: "limit")
    }
    
    /// https://docs.upbit.com/reference#주문하기
    private func requestOrder(market: String, side: String, volume: String, price: String, ord_type: String, identifier: String? = nil) -> RestAPISingleResult<OrderModel> {
        let volumeDouble = Double(volume) ?? 0.0
        let priceDouble = Double(price) ?? 0.0
        
        // 혹시라도 너무 큰 금액은 일단 방어
        guard volumeDouble * priceDouble < 100000 else {
            UIAlertController.simpleAlert(message: "너무 큰 거래 금액: \(volumeDouble * priceDouble)")
            return .error(OrderError.largePrice)
        }
        
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
    
    func requestOrders(market: String, page: Int, limit: Int) -> RestAPISingleResult<[OrderModel]> {
        let path = "/v1/orders"
        let request = RestAPIClientBuilder(path: path, method: .get, headers: [:], needAuth: true)
            .set(queryName: "market", queryValue: market)
            .set(queryName: "states[]", queryValue: "done")
            .set(queryName: "states[]", queryValue: "wait")
            /*.set(queryName: "states[]", queryValue: "cancel")*/
            .set(queryName: "page", queryValue: "\(page)")
            .set(queryName: "limit", queryValue: "\(limit)")
            .build()
        return RestAPIClient.shared.request(request: request, type: [OrderModel].self)
    }
    
    func requestCancelOrder(uuid: String) -> RestAPISingleResult<OrderModel> {
        let path = "/v1/order"
        let request = RestAPIClientBuilder(path: path, method: .delete, headers: [:], needAuth: true)
            .set(queryName: "uuid", queryValue: uuid)
            .build()
        return RestAPIClient.shared.request(request: request, type: OrderModel.self)
    }
}
