//
//  DietFoodData.swift
//  BalanceEat
//
//  Created by 김견 on 9/21/25.
//
import Foundation

struct DietFoodData: Equatable {
    let id: Int
    let name: String
    var intake: Double
    let servingSize: Double
    let unit: String
    let calories: Double
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    
}
