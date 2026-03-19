//
//  ActivityLevel.swift
//  BalanceEat
//
//  Created by 김견 on 3/19/26.
//

import Foundation

enum ActivityLevel: String, Codable {
    case sedentary = "SEDENTARY"
    case light = "LIGHT"
    case moderate = "MODERATE"
    case active = "ACTIVE"
    case none

    var emoji: String {
        switch self {
        case .sedentary: "🛋️"
        case .light:     "🚶"
        case .moderate:  "🏃"
        case .active:    "💪"
        default:         ""
        }
    }

    var title: String {
        switch self {
        case .sedentary: "거의 움직이지 않음"
        case .light:     "가벼운 활동"
        case .moderate:  "중간 활동"
        case .active:    "고강도 활동"
        default:         ""
        }
    }

    var subtitle: String {
        switch self {
        case .sedentary: "사무직, 재택근무"
        case .light:     "가벼운 운동 1-3일/주"
        case .moderate:  "중강도 운동 3-5일/주"
        case .active:    "고강도 운동 6-7일/주"
        default:         ""
        }
    }

    var description: String {
        switch self {
        case .sedentary: "하루 대부분을 앉아서 보내며, 운동을 거의 하지 않음"
        case .light:     "산책, 가벼운 집안일, 주 1-3회 가벼운 운동"
        case .moderate:  "조깅, 헬스장, 주 3-5회 중강도 운동"
        case .active:    "매일 운동, 고강도 트레이닝, 육체적 직업"
        default:         ""
        }
    }

    var coefficient: Double {
        switch self {
        case .sedentary: 1.2
        case .light:     1.375
        case .moderate:  1.55
        case .active:    1.725
        case .none:      0
        }
    }
}
