//
//  ReminderListResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderListResponseDTO: Codable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let items: [ReminderResponseDTO]
    let totalPages: Int
    
    func DTOToModel() -> ReminderListData {
        ReminderListData(
            totalItems: self.totalItems,
            currentPage: self.currentPage,
            itemsPerPage: self.itemsPerPage,
            items: self.items.map { $0.DTOToModel() },
            totalPages: self.totalPages
        )
    }
}

struct ReminderResponseDTO: Codable {
    let id: Int
    let content: String
    let sendTime: String
    let isActive: Bool
    let dayOfWeeks: [String]
    
    func DTOToModel() -> ReminderData {
        ReminderData(
            id: self.id,
            content: self.content,
            sendTime: self.sendTime,
            isActive: self.isActive,
            dayOfWeeks: self.dayOfWeeks
        )
    }
}
