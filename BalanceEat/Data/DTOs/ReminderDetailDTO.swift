//
//  ReminderDetailDTO.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderDetailDTO: Codable {
    let id: Int
    let userId: Int
    let content: String
    let sendTime: String
    let isActive: Bool
    let dayOfWeeks: [String]
    let createdAt: String
    let updatedAt: String
    
    func DTOToModel() -> ReminderDetailData {
        ReminderDetailData(
            id: self.id,
            userId: self.userId,
            content: self.content,
            sendTime: self.sendTime,
            isActive: self.isActive,
            dayOfWeeks: self.dayOfWeeks,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}
