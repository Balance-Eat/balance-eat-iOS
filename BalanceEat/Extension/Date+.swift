//
//  Date+.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

extension Date {
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .current 
        return formatter.string(from: self)
    }
}
