//
//  OrderModel.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/09.
//

import Foundation

/// https://docs.upbit.com/reference#주문하기
struct OrderModel: Decodable {

    /*
     uuid    주문의 고유 아이디    String
     side    주문 종류    String
     ord_type    주문 방식    String
     price    주문 당시 화폐 가격    NumberString
     avg_price    체결 가격의 평균가    NumberString
     state    주문 상태    String
     market    마켓의 유일키    String
     created_at    주문 생성 시간    String
     volume    사용자가 입력한 주문 양    NumberString
     remaining_volume    체결 후 남은 주문 양    NumberString
     reserved_fee    수수료로 예약된 비용    NumberString
     remaining_fee    남은 수수료    NumberString
     paid_fee    사용된 수수료    NumberString
     locked    거래에 사용중인 비용    NumberString
     executed_volume    체결된 양    NumberString
     trade_count    해당 주문에 걸린 체결 수    Integer
     */
    let uuid: String
    
    // 주문 종류 (필수)
    // - bid : 매수
    // - ask : 매도
    let side: String
    let ord_type: String
    let price: String?
    let avg_price: String?
    let state: String
    let market: String
    let created_at: String
    let volume: String?
    let remaining_volume: String?
    let reserved_fee: String
    let remaining_fee: String
    let paid_fee: String
    let locked: String
    let executed_volume: String
    let trade_count: Int?
}

// MARK: - Additional
extension OrderModel {
    
    var sideValue: String {
        switch side {
        case "bid": return "매도"
        case "ask": return "매수"
        default: return ""
        }
    }
    var sideColor: UIColor {
        switch side {
        case "bid": return .myBlue
        case "ask": return .myRed
        default: return UIColor.label
        }
    }
    
    var stateValue: String {
        switch state {
        case "done": return "완료"
        case "wait": return "대기"
        case "cancel": return "취소"
        default: return ""
        }
    }
}
