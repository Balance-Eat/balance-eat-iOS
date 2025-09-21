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
}
