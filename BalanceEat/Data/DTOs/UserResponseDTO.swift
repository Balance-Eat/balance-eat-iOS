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
    let email: String
    let gender: Gender
    let age: Int
    let weight: Double
    let height: Double
    let activityLevel: ActivityLevel
    let smi: Double
    let fatPercentage: Double
    let targetWeight: Double
    let targetCalorie: Int
    let targetSmi: Double
    let targetFatPercentage: Double
    let providerId: String
    let providerType: String
}

