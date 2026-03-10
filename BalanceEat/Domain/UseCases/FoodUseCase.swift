//
//  FoodUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

protocol FoodUseCaseProtocol {
    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodData, NetworkError>
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult,
                                                                            NetworkError>
}

struct FoodUseCase: FoodUseCaseProtocol {
    private let repository: FoodRepositoryProtocol
    
    init(repository: FoodRepositoryProtocol) {
        self.repository = repository
    }
    
    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodData, NetworkError> {
        await repository.createFood(createFoodDTO: createFoodDTO)
    }
    
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult, NetworkError> {
          await repository.searchFood(foodName: foodName, page: page, size: size)
      }
}
