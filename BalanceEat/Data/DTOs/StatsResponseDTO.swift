//
//  StatsResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 10/21/25.
//

import Foundation

struct StatsResponseDTO: Codable {
    let type: String
    let date: String
    let totalCalories: Double
    let totalCarbohydrates: Double
    let totalProtein: Double
    let totalFat: Double
    
    func DTOToModel() -> StatsData {
        StatsData(
            type: Period(rawValue: self.type) ?? .daily,
            date: self.date,
            totalCalories: self.totalCalories,
            totalCarbohydrates: self.totalCarbohydrates,
            totalProtein: self.totalProtein,
            totalFat: self.totalFat
        )
    }
}
