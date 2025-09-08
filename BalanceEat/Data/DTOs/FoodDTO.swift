//
//  FoodDTO.swift
//  BalanceEat
//
//  Created by 김견 on 9/8/25.
//

import Foundation

struct FoodDTO: Codable {
    let id: Int
    let uuid: String
    let name: String
    let perCapitaIntake: Double
    let unit: String
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let createdAt: String
}
