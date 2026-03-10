//
//  GoalType.swift
//  BalanceEat
//
//  Created by 김견 on 9/12/25.
//

import Foundation

enum GoalType: String, Codable {
    case diet = "DIET"
    case bulkUp = "BULK_UP"
    case maintain = "MAINTAIN"
    case none

    var title: String {
        switch self {
        case .diet:
            return "DIET"
        case .bulkUp:
            return "BULK_UP"
        case .maintain:
            return "MAINTAIN"
        case .none:
            return ""
        }
    }

    var coefficient: Double {
        switch self {
        case .diet:
            return 0.8
        case .bulkUp:
            return 1.15
        case .maintain:
            return 1
        case .none:
            return 0
        }
    }

    var description: String {
        switch self {
        case .diet:
            return "다이어트 🔥"
        case .bulkUp:
            return "근육량 증가 💪"
        case .maintain:
            return "현재 체중 유지 ⚖️"
        case .none:
            return ""
        }
    }

    var recommendedCarbonRatio: Double {
        switch self {
        case .diet:
            return 0.35
        case .bulkUp:
            return 0.5
        case .maintain:
            return 0.45
        case .none:
            return 0
        }
    }

    var recommendedProteinRatio: Double {
        switch self {
        case .diet:
            return 0.4
        case .bulkUp:
            return 0.3
        case .maintain:
            return 0.3
        case .none:
            return 0
        }
    }

    var recommendedFatRatio: Double {
        switch self {
        case .diet:
            return 0.25
        case .bulkUp:
            return 0.2
        case .maintain:
            return 0.25
        case .none:
            return 0
        }
    }
}
