//
//  NutritionalInfo.swift
//  BalanceEat
//
//  Created by 김견 on 7/9/25.
//

import Foundation

struct NutritionalInfo: Equatable, Codable {
    var calories: Double
    var carbs: Double
    var protein: Double
    var fat: Double
    
    static let zero = NutritionalInfo(calories: 0, carbs: 0, protein: 0, fat: 0)
    
    static func + (lhs: NutritionalInfo, rhs: NutritionalInfo) -> NutritionalInfo {
        return NutritionalInfo(
            calories: lhs.calories + rhs.calories,
            carbs: lhs.carbs + rhs.carbs,
            protein: lhs.protein + rhs.protein,
            fat: lhs.fat + rhs.fat
        )
    }
}
