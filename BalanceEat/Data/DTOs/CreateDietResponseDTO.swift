//
//  CreateDietResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 9/23/25.
//

import Foundation

struct CreateDietResponseDTO: Codable {
    let dietId: Int
    let userId: Int
    let mealType: String
    let consumedAt: String
    let totalNutrition: NutritionForCreateDietDTO
    let dietFoods: [DietFoodForCreateDietDTO]
}

struct NutritionForCreateDietDTO: Codable {
    let calories: Int
    let carbohydrates: Int
    let protein: Int
    let fat: Double
}

struct DietFoodForCreateDietDTO: Codable {
    let id: Int
    let foodId: Int
    let foodName: String
    let intake: Int
    let nutrition: FoodNutritionForCreateDietDTO
}

struct FoodNutritionForCreateDietDTO: Codable {
    let calories: Int
    let carbohydrates: Int
    let protein: Int
    let fat: Double
}
