//
//  FoodCreateRequest.swift
//  BalanceEat
//
//  Created by 김견 on 3/19/26.
//

import Foundation

struct FoodCreateRequest {
    let uuid: String
    let name: String
    let servingSize: Double
    let unit: String
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let brand: String
}
