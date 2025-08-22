//
//  NutritionData.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//


struct DailyDietResponseDTO: Codable {
    let dailyTotal: DailyTotal
    let diets: [Diet]
}

struct DailyTotal: Codable {
    let totalCalorie: Int
    let totalCarbohydrates: Int
    let totalProtein: Int
    let totalFat: Int
}

struct Diet: Codable {
    let dietId: Int
    let eatingAt: String
    let type: String
    let items: [FoodItem]
}

struct FoodItem: Codable {
    let foodId: Int
    let foodName: String
    let intake: Int
    let unit: String
    let calories: Int
    let carbohydrates: Int
    let protein: Int
    let fat: Int
}
