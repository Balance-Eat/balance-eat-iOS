//
//  DietRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

struct DietRepository: DietRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        let dtoFoods = dietFoods.map { FoodItemForCreateDietDTO(foodId: $0.foodId, intake: $0.intake) }
        let endPoint = DietEndPoints.createDiet(mealType: mealType, consumedAt: consumedAt, dietFoods:
                                                    dtoFoods, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<CreateDietResponseDTO>.self
        )
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        let dtoFoods = dietFoods.map { FoodItemForCreateDietDTO(foodId: $0.foodId, intake: $0.intake) }
        let endPoint = DietEndPoints.updateDiet(dietId: dietId, mealType: mealType, consumedAt: consumedAt, dietFoods: dtoFoods, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<CreateDietResponseDTO>.self
        )
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError> {
        let endPoint = DietEndPoints.deleteDiet(dietId: dietId, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: EmptyResponse.self
        )
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietData], NetworkError> {
        let endpoint = DietEndPoints.daily(date: date.toString(), userId: userId)
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: BaseResponse<[DietDTO]>.self
        )
        
        switch result {
        case .success(let response):
            return .success(response.data.map { $0.toDietData() })
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietData], NetworkError> {
        let formattedMonth = String(format: "%02d", month)
        let endPoint = DietEndPoints.monthly(yearMonth: "\(year)-\(formattedMonth)", userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<[DietDTO]>.self
        )
        
        switch result {
        case .success(let response):
            return .success(response.data.map { $0.toDietData() })
        case .failure(let error):
            return .failure(error)
        }
    }
}
