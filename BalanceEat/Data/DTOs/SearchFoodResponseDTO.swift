//
//  SearchFoodResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 9/22/25.
//

import Foundation

struct SearchFoodResponseDTO: Codable {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let items: [FoodDTOForSearch]
}

struct FoodDTOForSearch: Codable {
    let id: Int
    let uuid: String
    let name: String
    let userId: Int
    let perCapitaIntake: Double
    let unit: String
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let brand: String
    let isAdminApproved: Bool
    let createdAt: String
    let updatedAt: String
    
    func toFoodData() -> FoodData {
        return FoodData(
            id: self.id,
            uuid: self.uuid,
            name: self.name,
            perCapitaIntake: self.perCapitaIntake,
            unit: self.unit,
            carbohydrates: self.carbohydrates,
            protein: self.protein,
            fat: self.fat,
            brand: self.brand,
            createdAt: self.createdAt
        )
    }
}
