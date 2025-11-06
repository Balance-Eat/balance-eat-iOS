//
//  CreateUserDTO.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import UIKit

struct UserDTO: Codable {
    let id: Int?
    let uuid: String
    let name: String
    let gender: Gender
    let age: Int
    let height: Double
    let weight: Double
    let goalType: GoalType
    let email: String?
    let activityLevel: ActivityLevel?
    let smi: Double?
    let fatPercentage: Double?
    let targetWeight: Double?
    let targetCalorie: Double?
    let targetSmi: Double?
    let targetFatPercentage: Double?
    let targetCarbohydrates: Double?
    let targetProtein: Double?
    let targetFat: Double?
    let providerId: String?
    let providerType: String?
    
    init(id: Int? = nil, uuid: String, name: String, gender: Gender, age: Int, height: Double, weight: Double, goalType: GoalType, email: String?, activityLevel: ActivityLevel?, smi: Double?, fatPercentage: Double?, targetWeight: Double?, targetCalorie: Double?, targetSmi: Double?, targetFatPercentage: Double?, targetCarbohydrates: Double?, targetProtein: Double?, targetFat: Double?, providerId: String?, providerType: String?) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.gender = gender
        self.age = age
        self.height = height.rounded(toPlaces: 2)
        self.weight = weight.rounded(toPlaces: 2)
        self.goalType = goalType
        self.email = email
        self.activityLevel = activityLevel
        self.smi = smi?.rounded(toPlaces: 2)
        self.fatPercentage = fatPercentage?.rounded(toPlaces: 2)
        self.targetWeight = targetWeight?.rounded(toPlaces: 2)
        self.targetCalorie = targetCalorie
        self.targetSmi = targetSmi?.rounded(toPlaces: 2)
        self.targetFatPercentage = targetFatPercentage?.rounded(toPlaces: 2)
        self.targetCarbohydrates = targetCarbohydrates?.rounded(toPlaces: 2)
        self.targetProtein = targetProtein?.rounded(toPlaces: 2)
        self.targetFat = targetFat?.rounded(toPlaces: 2)
        self.providerId = providerId
        self.providerType = providerType
    }
}


enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case none
}

enum ActivityLevel: String, Codable {
    case sedentary = "SEDENTARY"
    case light = "LIGHT"
    case moderate = "MODERATE"
    case active = "ACTIVE"
    case none
    
    var emoji: String {
        switch self {
        case .sedentary:
            "🛋️"
        case .light:
            "🚶"
        case .moderate:
            "🏃"
        case .active:
            "💪"
        default:
            ""
        }
    }
    
    var title: String {
        switch self {
        case .sedentary:
            "거의 움직이지 않음"
        case .light:
            "가벼운 활동"
        case .moderate:
            "중간 활동"
        case .active:
            "고강도 활동"
        default:
            ""
        }
    }
    
    var subtitle: String {
        switch self {
        case .sedentary:
            "사무직, 재택근무"
        case .light:
            "가벼운 운동 1-3일/주"
        case .moderate:
            "중강도 운동 3-5일/주"
        case .active:
            "고강도 운동 6-7일/주"
        default:
            ""
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:
            "하루 대부분을 앉아서 보내며, 운동을 거의 하지 않음"
        case .light:
            "산책, 가벼운 집안일, 주 1-3회 가벼운 운동"
        case .moderate:
            "조깅, 헬스장, 주 3-5회 중강도 운동"
        case .active:
            "매일 운동, 고강도 트레이닝, 육체적 직업"
        default:
            ""
        }
    }
    
    var selectedBorderColor: UIColor {
        switch self {
        case .sedentary:
                .sedentarySelectedBorder
        case .light:
                .lightSelectedBorder
        case .moderate:
                .moderateSelectedBorder
        case .active:
                .vigorousSelectedBorder
        default:
                .clear
        }
    }
    
    var coefficient: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .light:
            return 1.375
        case .moderate:
            return 1.55
        case .active:
            return 1.725
        case .none:
            return 0
        }
    }
}
