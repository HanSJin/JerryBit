//
//  Date+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/11.
//

import Foundation

extension DateFormatter {

    static var defaultFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        return dateFormatter
    }
}

extension Date {

    func toStringWithFormat(to format: String, locale: Locale? = nil) -> String? {
        let dateFormatter = DateFormatter()
        if let locale = locale {
            dateFormatter.locale = locale
        }
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func toStringWithDefaultFormat() -> String {
        DateFormatter.defaultFormatter.string(from: self)
    }
}
