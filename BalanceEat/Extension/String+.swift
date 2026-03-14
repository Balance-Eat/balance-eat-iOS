//
//  String+.swift
//  BalanceEat
//
//  Created by 김견 on 8/25/25.
//

import Foundation


extension String {
    private static let defaultFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func toDate(format: String = "yyyy-MM-dd HH:mm:ss",
                locale: Locale = Locale(identifier: "ko_KR"),
                timeZone: TimeZone? = TimeZone(identifier: "Asia/Seoul")) -> Date? {
        if format == "yyyy-MM-dd HH:mm:ss" && locale.identifier == "ko_KR" && timeZone?.identifier == "Asia/Seoul" {
            return String.defaultFormatter.date(from: self)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone ?? TimeZone.current
        return formatter.date(from: self)
    }
}
