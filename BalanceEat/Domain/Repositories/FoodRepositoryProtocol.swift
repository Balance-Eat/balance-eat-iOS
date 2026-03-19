//
//  FoodRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

protocol FoodRepositoryProtocol {
    func createFood(_ request: FoodCreateRequest) async -> Result<FoodData, NetworkError>
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult, NetworkError>
}
