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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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

extension String {

    /*
     Inputs
      "2021-03-20T23:44:03z"
      "2021-03-20T23:44:03Z"
      "2021-03-20T23:44:03+09:00"
      "2021-03-20T23:44:03.123+09:00"
      "2021-03-20T23:44:03.1234567+09:00"
     Out: Date()
     */
    func toDateWithDefaultFormat() -> Date? {
        DateFormatter.defaultFormatter.date(from: self)
    }
    
   func toStringWithDefaultFormat() -> String? {
        let dateFormatter = DateFormatter.defaultFormatter
        guard let dt = dateFormatter.date(from: self) else {
            return nil
        }
        return dateFormatter.string(from: dt)
   }

    // In: 2019-11-10T07:02:01.125Z
    // Out: format (ex. 2019-11-10)
    func changeLocalTimeFormat(to format: String) -> String? {
        let dateFormatter = DateFormatter.defaultFormatter
        guard let dt = dateFormatter.date(from: self) else {
            return nil
        }
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: dt)
    }
}
