//
//  NotificationRequestDTO.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

struct NotificationRequestDTO: Codable {
    let agentId: String
    let osType: String
    let deviceName: String
    let isActive: Bool
}
