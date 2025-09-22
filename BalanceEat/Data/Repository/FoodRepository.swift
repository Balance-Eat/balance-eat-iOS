//
//  FoodRepository.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation

struct FoodRepository: FoodRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodDTO, NetworkError> {
        let endPoint = FoodEndPoints.create(createFoodDTO: createFoodDTO)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<FoodDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("create food success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("create food failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func searchFood(foodName: String, page: Int, size: Int) async -> Result<SearchFoodResponseDTO, NetworkError> {
        let endPoint = FoodEndPoints.search(foodName: foodName, page: page, size: size)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<SearchFoodResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("search food success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("search food failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
