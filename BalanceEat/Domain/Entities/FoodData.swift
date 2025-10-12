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
            carbohydrates: self.carbohydrates,
            protein: self.protein,
            fat: self.fat,
            brand: self.brand,
            createdAt: self.createdAt
        )
    }
    
    func modelToDietFoodData() -> DietFoodData {
        DietFoodData(
            id: self.id,
            name: self.name,
            intake: self.servingSize,
            unit: self.unit,
            calories: self.carbohydrates * 4 + self.protein * 4 + self.fat * 9,
            carbohydrates: self.carbohydrates,
            protein: self.protein,
            fat: self.fat
        )
    }
}
