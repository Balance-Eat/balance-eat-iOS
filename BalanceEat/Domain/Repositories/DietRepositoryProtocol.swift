//
//  DietRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietRepositoryProtocol {
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async -> Result<CreateDietResponseDTO, NetworkError>
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError>
    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietDTO], NetworkError>
}
