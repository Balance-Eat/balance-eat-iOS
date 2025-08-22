//
//  FoodItem.swift
//  BalanceEat
//
//  Created by 김견 on 7/9/25.
//

import Foundation

struct FooddddItem: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let amount: Double
    let unit: String
    let nutritionalInfo: NutritionalInfo
    
    init(id: UUID, name: String, amount: Double, unit: String, nutritionalInfo: NutritionalInfo) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.nutritionalInfo = nutritionalInfo
    }
}
