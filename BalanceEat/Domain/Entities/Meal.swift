//
//  Meal.swift
//  BalanceEat
//
//  Created by 김견 on 7/9/25.
//

import Foundation

enum MealType: String, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
}

struct Meal: Identifiable, Equatable, Codable {
    let id: UUID
    let date: Date
    let type: MealType
    var foodItems: [FoodItem]
    
    init(id: UUID, date: Date, type: MealType, foodItems: [FoodItem]) {
        self.id = id
        self.date = date
        self.type = type
        self.foodItems = foodItems
    }
    
    
}
