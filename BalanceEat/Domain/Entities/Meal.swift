//
//  Meal.swift
//  BalanceEat
//
//  Created by 김견 on 7/9/25.
//

import Foundation

enum MealType: String, Codable {
    case breakfast = "BREAKFAST"
    case lunch = "LUNCH"
    case dinner = "DINNER"
    case snack = "SNACK"
    
    var title : String {
        switch self {
        case .breakfast:
            return "아침"
        case .lunch:
            return "점심"
        case .dinner:
            return "저녁"
        case .snack:
            return "간식"
        }
    }
    
    var icon: String {
        switch self {
            case .breakfast:
            return "sunrise"
        case .lunch:
            return "sun.min.fill"
        case .dinner:
            return "fork.knife.circle.fill"
        case .snack:
            return "takeoutbag.and.cup.and.straw"
        }
    }
}

struct Meal: Identifiable, Equatable, Codable {
    let id: UUID
    let date: Date
    let type: MealType
    var foodItems: [FooddddItem]
    
    init(id: UUID, date: Date, type: MealType, foodItems: [FooddddItem]) {
        self.id = id
        self.date = date
        self.type = type
        self.foodItems = foodItems
    }
    
    
}
