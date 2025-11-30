//
//  NotificationResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

struct NotificationResponseDTO: Codable {
    let id: Int
    let userId: Int
    let agentId: String
    let osType: String
    let deviceName: String
    let isActive: Bool
    
    func DTOToModel() -> NotificationData {
        NotificationData(
            id: self.id,
            userId: self.userId,
            agentId: self.agentId,
            osType: self.osType,
            deviceName: self.deviceName,
            isActive: self.isActive
        )
    }
}
