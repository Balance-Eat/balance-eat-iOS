//
//  FoodUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

protocol FoodUseCaseProtocol {
    func createFood(request: FoodCreateRequest) async -> Result<FoodData, NetworkError>
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult, NetworkError>
}

struct FoodUseCase: FoodUseCaseProtocol {
    private let repository: FoodRepository

    init(repository: FoodRepository) {
        self.repository = repository
    }

    func createFood(request: FoodCreateRequest) async -> Result<FoodData, NetworkError> {
        await repository.createFood(request: request)
    }

    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult, NetworkError> {
        await repository.searchFood(foodName: foodName, page: page, size: size)
    }
}
