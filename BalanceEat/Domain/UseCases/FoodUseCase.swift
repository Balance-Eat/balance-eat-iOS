//
//  FoodUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

protocol FoodUseCaseProtocol {
    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodData, NetworkError>
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<SearchFoodResponseDTO, NetworkError>
}

struct FoodUseCase: FoodUseCaseProtocol {
    private let repository: FoodRepositoryProtocol
    
    init(repository: FoodRepositoryProtocol) {
        self.repository = repository
    }
    
    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodData, NetworkError> {
        let response = await repository.createFood(createFoodDTO: createFoodDTO)
        
        switch response {
        case .success(let foodDTO):
            return .success(foodDTO.DTOToModel())
        case .failure(let failure):
            return .failure(failure)
        }
    }
    
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<SearchFoodResponseDTO, NetworkError> {
        let response = await repository.searchFood(foodName: foodName, page: page, size: size)
        
        switch response {
        case .success(let searchFoodResponseDTO):
            return .success(searchFoodResponseDTO)
        case .failure(let failure):
            return .failure(failure)
        }
    }
}
