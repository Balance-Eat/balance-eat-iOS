//
//  NutritionData.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//
import Foundation

struct DietDTO: Codable {
    let dietId: Int
    let consumedAt: String
    let mealType: String
    let items: [FoodItemForDietDTO]
}

struct FoodItemForDietDTO: Codable {
    let foodId: Int
    let foodName: String
    let intake: Double
    let unit: String
    let calories: Double
    let carbohydrates: Double
    let protein: Double
    let fat: Double
}

struct FoodItemForCreateDietDTO: Codable {
    let foodId: Int
    let intake: Double
    
    func toDictionary() -> [String: Any] {
        return [
            "foodId": foodId,
            "intake": intake
        ]
    }
}

extension DietDTO {
    func toDietData() -> DietData {
        return DietData(
            id: dietId,
            consumedAt: consumedAt,
            mealType: MealType(rawValue: mealType) ?? .breakfast,
            items: items.map { $0.toDietFoodData() }
        )
    }
}

extension FoodItemForDietDTO {
    func toDietFoodData() -> DietFoodData {
        return DietFoodData(
            id: foodId,
            name: foodName,
            intake: intake,
            unit: unit,
            calories: calories,
            carbohydrates: carbohydrates,
            protein: protein,
            fat: fat
        )
    }
}
