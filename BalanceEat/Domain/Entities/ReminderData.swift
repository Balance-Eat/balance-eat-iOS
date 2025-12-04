//
//  ReminderData.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderData {
    let id: Int
    let content: String
    let sendTime: String
    var isActive: Bool
    let dayOfWeeks: [String]
}
