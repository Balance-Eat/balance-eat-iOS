//
//  CreateFoodDTO.swift
//  BalanceEat
//
//  Created by 김견 on 9/21/25.
//

import Foundation

struct CreateFoodDTO: Codable {
    let uuid: String
    let name: String
    let servingSize: Double
    let unit: String
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let brand: String
}
