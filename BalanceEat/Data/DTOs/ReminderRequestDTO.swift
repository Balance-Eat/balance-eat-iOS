//
//  CreateReminderRequestDTO.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderRequestDTO: Codable {
    let content: String
    let sendTime: String
    let isActive: Bool
    let dayOfWeeks: [String]
}
