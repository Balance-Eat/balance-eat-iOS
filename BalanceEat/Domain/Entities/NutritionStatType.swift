//
//  NutritionStat.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

enum NutritionStatType: Codable {
    case calorie
    case carbohydrate
    case protein
    case fat
    case weight
    
    var unit: String {
        switch self {
        case .calorie: return "kcal"
        case .carbohydrate: return "g"
        case .protein: return "g"
        case .fat: return "g"
        case .weight: return "kg"
        }
    }
}
