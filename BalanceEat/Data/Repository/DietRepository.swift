//
//  DietRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

struct DietRepository: DietRepositoryProtocol {
    private let apiClient = APIClient.shared
    
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError> {
        let endPoint = DietEndPoints.createDiet(mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<CreateDietResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("create diet success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("create diet failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError> {
        let endPoint = DietEndPoints.updateDiet(dietId: dietId, mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<CreateDietResponseDTO>.self
        )
        
        switch result {
        case .success(let response):
            print("update diet success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("update diet failed: \(error.localizedDescription)")
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
        case .success(let response):
            print("delete diet success \(response)")
            return .success(())
        case .failure(let error):
            print("delete diet failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError> {
        let endpoint = DietEndPoints.daily(date: date.toString(), userId: userId)
        let result = await apiClient.request(
            endpoint: endpoint,
            responseType: BaseResponse<[DietDTO]>.self
        )
        
        switch result {
        case .success(let response):
            print("get daily diet success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("get daily diet failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietDTO], NetworkError> {
        let formattedMonth = String(format: "%02d", month)
        let endPoint = DietEndPoints.monthly(yearMonth: "\(year)-\(formattedMonth)", userId: userId)
        let result = await apiClient.request(
            endpoint: endPoint,
            responseType: BaseResponse<[DietDTO]>.self
        )
        
        switch result {
        case .success(let response):
            print("get monthly diet success \(response)")
            return .success(response.data)
        case .failure(let error):
            print("get monthly diet failed: \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
