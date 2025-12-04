//
//  ReminderDetailData.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderDetailData {
    let id: Int
    let userId: Int
    let content: String
    let sendTime: String
    var isActive: Bool
    let dayOfWeeks: [String]
    let createdAt: String
    let updatedAt: String
}
