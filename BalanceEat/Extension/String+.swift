//
//  String+.swift
//  BalanceEat
//
//  Created by 김견 on 8/25/25.
//

import Foundation


extension String {
    func toDate(format: String = "yyyy-MM-dd HH:mm",
                locale: Locale = Locale(identifier: "ko_KR"),
                timeZone: TimeZone? = TimeZone(identifier: "Asia/Seoul")) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        formatter.timeZone = timeZone ?? TimeZone.current
        return formatter.date(from: self)
    }
}
