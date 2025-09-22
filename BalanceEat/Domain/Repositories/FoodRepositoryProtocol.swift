//
//  FoodRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

protocol FoodRepositoryProtocol {
    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodDTO, NetworkError>
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<SearchFoodResponseDTO, NetworkError>
}
