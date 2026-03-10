//
//  FoodSearchResult.swift
//  BalanceEat
//
//  Created by 김견 on 2/25/26.
//

import Foundation

struct FoodSearchResult {
    let totalItems: Int
    let currentPage: Int
    let itemsPerPage: Int
    let totalPages: Int
    let items: [FoodData]
}
