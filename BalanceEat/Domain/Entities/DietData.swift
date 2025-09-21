//
//  DietData.swift
//  BalanceEat
//
//  Created by 김견 on 9/21/25.
//

import Foundation

struct DietData {
    let id: Int
    let consumedAt: String
    let mealType: MealType
    let items: [DietFoodData]
}
