//
//  UserCreateRequest.swift
//  BalanceEat
//
//  Created by 김견 on 3/19/26.
//

import Foundation

struct UserCreateRequest {
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
}
