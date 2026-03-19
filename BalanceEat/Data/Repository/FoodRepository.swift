//
//  FoodRepository.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

struct FoodRepository: FoodRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func createFood(_ request: FoodCreateRequest) async -> Result<FoodData, NetworkError> {
        let createFoodDTO = CreateFoodDTO(
            uuid: request.uuid,
            name: request.name,
            servingSize: request.servingSize,
            unit: request.unit,
            carbohydrates: request.carbohydrates,
            protein: request.protein,
            fat: request.fat,
            brand: request.brand
        )
        let endPoint = FoodEndPoints.create(createFoodDTO: createFoodDTO)
        let result = await apiClient.request(endpoint: endPoint, responseType: BaseResponse<FoodDTO>.self)
        switch result {
        case .success(let response): return .success(response.data.DTOToModel())
        case .failure(let error):    return .failure(error)
        }
    }
    
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult, NetworkError> {
        let endPoint = FoodEndPoints.search(foodName: foodName, page: page, size: size)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<SearchFoodResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            let dto = response.data
            let result = FoodSearchResult(
                totalItems: dto.totalItems,
                currentPage: dto.currentPage,
                itemsPerPage: dto.itemsPerPage,
                totalPages: dto.totalPages,
                items: dto.items.map { $0.toFoodData() }
            )
            return .success(result)
        case .failure(let error):
            return .failure(error)
        }
    }
}
