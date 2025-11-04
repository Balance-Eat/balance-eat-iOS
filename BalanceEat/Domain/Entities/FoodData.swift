//
//  FoodData.swift
//  BalanceEat
//
//  Created by 김견 on 9/16/25.
//

import Foundation

struct FoodData {
    let id: Int
    let uuid: String
    let name: String
    let servingSize: Double
    let unit: String
    let perServingCalories: Double
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    var brand: String
    let createdAt: String
    
    func modelToDTO() -> FoodDTO
    {
        FoodDTO(
            id: self.id,
            uuid: self.uuid,
            name: self.name,
            servingSize: self.servingSize,
            unit: self.unit,
            perServingCalories: self.perServingCalories,
            carbohydrates: self.carbohydrates,
            protein: self.protein,
            fat: self.fat,
            brand: self.brand,
            createdAt: self.createdAt
        )
    }
    
    func modelToDietFoodData(intake: Double) -> DietFoodData {
        DietFoodData(
            id: self.id,
            name: self.name,
            intake: intake,
            servingSize: self.servingSize,
            unit: self.unit,
            calories: self.perServingCalories,
            carbohydrates: self.carbohydrates,
            protein: self.protein,
            fat: self.fat
        )
    }
}
