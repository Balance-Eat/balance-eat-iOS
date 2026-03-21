//
//  DietRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietRepository {
      func createDiet(mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String)
  async -> Result<Void, NetworkError>
      func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest],
  userId: String) async -> Result<Void, NetworkError>
      func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError>
      func getDailyDiet(date: Date, userId: String) async -> Result<[DietData], NetworkError>
      func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietData], NetworkError>
}
