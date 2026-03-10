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
}
