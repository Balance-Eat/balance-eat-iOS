//
//  DietUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietUseCaseProtocol {
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError>
    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError>
    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError>
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError>
    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietDTO], NetworkError>
}

struct DietUseCase: DietUseCaseProtocol {
    private let repository: DietRepositoryProtocol
    
    init(repository: DietRepositoryProtocol) {
        self.repository = repository
    }
    
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError> {
        await repository.createDiet(mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
    }
    
    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError> {
        await repository.updateDiet(dietId: dietId, mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
    }
    
    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError> {
        await repository.deleteDiet(dietId: dietId, userId: userId)
    }
    
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError> {
        await repository.getDailyDiet(date: date, userId: userId)
    }
    
    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietDTO], NetworkError> {
        await repository.getMonthlyDiet(year: year, month: month, userId: userId)
    }
}
