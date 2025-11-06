//
//  UserResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 8/21/25.
//


struct UserResponseDTO: Codable {
    let id: Int
    let uuid: String
    let name: String
    let email: String?
    let gender: Gender
    let age: Int
    let weight: Double
    let height: Double
    let goalType: GoalType
    let activityLevel: ActivityLevel
    let smi: Double?
    let fatPercentage: Double?
    let targetWeight: Double
    let targetCalorie: Double
    let targetSmi: Double?
    let targetFatPercentage: Double?
    let targetCarbohydrates: Double?
    let targetProtein: Double?
    let targetFat: Double?
    let providerId: String?
    let providerType: String?
    
    enum CodingKeys: String, CodingKey {
            case id, uuid, name, email, gender, age, weight, height, activityLevel, smi, fatPercentage, goalType
            case targetWeight, targetCalorie, targetSmi, targetFatPercentage
            case targetCarbohydrates = "targetCarbohydrates"
            case targetProtein = "targetProtein"
            case targetFat = "targetFat"
            case providerId, providerType
        }
}

