//
//  Date+.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

extension Date {
    private static let defaultFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func toString(format: String = "yyyy-MM-dd") -> String {
        if format == "yyyy-MM-dd" {
            return Date.defaultFormatter.string(from: self)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter.string(from: self)
    }
}
