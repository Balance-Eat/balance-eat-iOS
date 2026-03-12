//
//  MockDietUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockDietUseCase: DietUseCaseProtocol {
    var createDietResult: Result<Void, NetworkError> = .success(())
    var updateDietResult: Result<Void, NetworkError> = .success(())
    var deleteDietResult: Result<Void, NetworkError> = .success(())
    var getDailyDietResult: Result<[DietData], NetworkError> = .success([])
    var getMonthlyDietResult: Result<[DietData], NetworkError> = .success([])

    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        createDietResult
    }

    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        updateDietResult
    }

    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError> {
        deleteDietResult
    }

    func getDailyDiet(date: Date, userId: String) async -> Result<[DietData], NetworkError> {
        getDailyDietResult
    }

    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietData], NetworkError> {
        getMonthlyDietResult
    }
}
