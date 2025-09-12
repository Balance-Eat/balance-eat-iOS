//
//  User.swift
//  BalanceEat
//
//  Created by 김견 on 9/12/25.
//

import Foundation

struct UserData {
    let id: Int
    let uuid: String
    let name: String
    let email: String?
    let gender: Gender
    let age: Int
    let weight: Double
    let height: Double
    let activityLevel: ActivityLevel
    let smi: Double?
    let fatPercentage: Double?
    let targetWeight: Double
    let targetCalorie: Int
    let targetSmi: Double?
    let targetFatPercentage: Double?
    let targetCarbohydrates: Double?
    let targetProtein: Double?
    let targetFat: Double?
    let providerId: String?
    let providerType: String?
    
    static func responseDTOToModel(userResponseDTO: UserResponseDTO) -> UserData {
        UserData(
            id: userResponseDTO.id,
            uuid: userResponseDTO.uuid,
            name: userResponseDTO.name,
            email: userResponseDTO.email,
            gender: userResponseDTO.gender,
            age: userResponseDTO.age,
            weight: userResponseDTO.weight,
            height: userResponseDTO.height,
            activityLevel: userResponseDTO.activityLevel,
            smi: userResponseDTO.smi,
            fatPercentage: userResponseDTO.fatPercentage,
            targetWeight: userResponseDTO.targetWeight,
            targetCalorie: userResponseDTO.targetCalorie,
            targetSmi: userResponseDTO.targetSmi,
            targetFatPercentage: userResponseDTO.targetFatPercentage,
            targetCarbohydrates: userResponseDTO.targetCarbohydrates,
            targetProtein: userResponseDTO.targetProtein,
            targetFat: userResponseDTO.targetFat,
            providerId: userResponseDTO.providerId,
            providerType: userResponseDTO.providerId
        )
    }
}
