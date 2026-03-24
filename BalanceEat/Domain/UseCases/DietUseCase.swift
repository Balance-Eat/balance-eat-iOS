//
//  DietUseCase.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietUseCaseProtocol {
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError>
    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError>
    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError>
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietData], NetworkError>
    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietData], NetworkError>
    func calculateNutritionAchievement(diets: [DietData], target: UserData) -> NutritionAchievement
}

struct DietUseCase: DietUseCaseProtocol {
    private let repository: DietRepository

    init(repository: DietRepository) {
        self.repository = repository
    }

    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        guard !dietFoods.isEmpty else { return .failure(.invalid) }
        guard !userId.isEmpty else { return .failure(.invalid) }
        return await repository.createDiet(mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
    }

    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        await repository.updateDiet(dietId: dietId, mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
    }

    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError> {
        await repository.deleteDiet(dietId: dietId, userId: userId)
    }

    func getDailyDiet(date: Date, userId: String) async -> Result<[DietData], NetworkError> {
        await repository.getDailyDiet(date: date, userId: userId)
    }

    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietData], NetworkError> {
        await repository.getMonthlyDiet(year: year, month: month, userId: userId)
    }

    func calculateNutritionAchievement(diets: [DietData], target: UserData) -> NutritionAchievement {
        let totalCalorie = diets.flatMap { $0.items }.reduce(0.0) { $0 + $1.calories }
        let totalCarbohydrate = diets.flatMap { $0.items }.reduce(0.0) { $0 + $1.carbohydrates }
        let totalProtein = diets.flatMap { $0.items }.reduce(0.0) { $0 + $1.protein }
        let totalFat = diets.flatMap { $0.items }.reduce(0.0) { $0 + $1.fat }

        let targetCalorie = target.targetCalorie
        let targetCarbohydrate = target.targetCarbohydrates ?? 0.0
        let targetProtein = target.targetProtein ?? 0.0
        let targetFat = target.targetFat ?? 0.0

        return NutritionAchievement(
            calorieRate: targetCalorie == 0 ? 0.0 : totalCalorie / targetCalorie,
            carbohydrateRate: targetCarbohydrate == 0 ? 0.0 : totalCarbohydrate / targetCarbohydrate,
            proteinRate: targetProtein == 0 ? 0.0 : totalProtein / targetProtein,
            fatRate: targetFat == 0 ? 0.0 : totalFat / targetFat
        )
    }
}
