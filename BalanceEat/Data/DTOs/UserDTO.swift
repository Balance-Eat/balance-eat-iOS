//
//  CreateUserDTO.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

struct UserDTO: Encodable {
    let id: Int?  // URL 경로 생성에만 사용, request body에는 포함하지 않음

    private enum CodingKeys: String, CodingKey {
        case uuid, name, gender, age, height, weight, goalType, email, activityLevel
        case smi, fatPercentage, targetWeight, targetCalorie, targetSmi
        case targetFatPercentage, targetCarbohydrates, targetProtein, targetFat
        case providerId, providerType
    }

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
