//
//  ReminderDataForCreate.swift
//  BalanceEat
//
//  Created by 김견 on 12/7/25.
//

import Foundation

struct ReminderDataForCreate {
    let content: String
    let sendTime: String
    let isActive: Bool
    let dayOfWeeks: [String]
    
    func modelToDTO() -> ReminderRequestDTO {
        return ReminderRequestDTO(
            content: self.content,
            sendTime: self.sendTime,
            isActive: self.isActive,
            dayOfWeeks: self.dayOfWeeks
        )
    }
}
