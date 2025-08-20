//
//  CreateUserDTO.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import UIKit

struct CreateUserDTO: Codable {
    let uuid: String
    let name: String
    let gender: Gender
    let age: Int
    let height: Double
    let weight: Double
    let email: String
    let activityLevel: ActivityLevel
    let smi: Double
    let fatPercentage: Double
    let targetWeight: Double
    let targetCalorie: Int
    let targetSmi: Double
    let targetFatPercentage: Double
    let providerId: String
    let providerType: String
    
    enum CodingKeys: String, CodingKey {
        case uuid, name, gender, age, height, weight, email, activityLevel, smi, fatPercentage,
             targetWeight, targetCalorie, targetSmi, targetFatPercentage, providerId, providerType
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try c.decodeIfPresent(String.self, forKey: .uuid) ?? ""
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.gender = (try? c.decode(Gender.self, forKey: .gender)) ?? .male
        self.age = (try? c.decode(Int.self, forKey: .age)) ?? 0
        self.height = (try? c.decode(Double.self, forKey: .height)) ?? 0
        self.weight = (try? c.decode(Double.self, forKey: .weight)) ?? 0
        self.email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.activityLevel = (try? c.decode(ActivityLevel.self, forKey: .activityLevel)) ?? .sedentary
        self.smi = (try? c.decode(Double.self, forKey: .smi)) ?? 0
        self.fatPercentage = (try? c.decode(Double.self, forKey: .fatPercentage)) ?? 0
        self.targetWeight = (try? c.decode(Double.self, forKey: .targetWeight)) ?? 0
        self.targetCalorie = (try? c.decode(Int.self, forKey: .targetCalorie)) ?? 0
        self.targetSmi = (try? c.decode(Double.self, forKey: .targetSmi)) ?? 0
        self.targetFatPercentage = (try? c.decode(Double.self, forKey: .targetFatPercentage)) ?? 0
        self.providerId = try c.decodeIfPresent(String.self, forKey: .providerId) ?? ""
        self.providerType = try c.decodeIfPresent(String.self, forKey: .providerType) ?? ""
    }
    
    init(
        uuid: String = "", name: String = "", gender: Gender = .male, age: Int = 0,
        height: Double = 0, weight: Double = 0, email: String = "",
        activityLevel: ActivityLevel = .sedentary, smi: Double = 0, fatPercentage: Double = 0,
        targetWeight: Double = 0, targetCalorie: Int = 0, targetSmi: Double = 0,
        targetFatPercentage: Double = 0, providerId: String = "", providerType: String = ""
    ) {
        self.uuid = uuid
        self.name = name
        self.gender = gender
        self.age = age
        self.height = height
        self.weight = weight
        self.email = email
        self.activityLevel = activityLevel
        self.smi = smi
        self.fatPercentage = fatPercentage
        self.targetWeight = targetWeight
        self.targetCalorie = targetCalorie
        self.targetSmi = targetSmi
        self.targetFatPercentage = targetFatPercentage
        self.providerId = providerId
        self.providerType = providerType
    }
}


enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    case none

    // 혹시 서버가 예기치 않은 값을 내려주면 기본값으로 보정
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Gender(rawValue: raw.uppercased()) ?? .male
    }
}

enum ActivityLevel: String, Codable {
    case sedentary = "SEDENTARY"
    case light = "LIGHT"
    case moderate = "MODERATE"
    case active = "ACTIVE"
    case none

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = ActivityLevel(rawValue: raw.uppercased()) ?? .sedentary
    }
    
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
