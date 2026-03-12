//
//  FoodData+Fixture.swift
//  BalanceEatTests
//

@testable import BalanceEat

extension FoodData {
    static func fixture(
        id: Int = 1,
        uuid: String = "food-uuid",
        name: String = "닭가슴살",
        servingSize: Double = 100,
        unit: String = "g",
        perServingCalories: Double = 165,
        carbohydrates: Double = 0,
        protein: Double = 31,
        fat: Double = 3.6,
        brand: String = "",
        createdAt: String = "2026-03-12T00:00:00"
    ) -> FoodData {
        FoodData(
            id: id,
            uuid: uuid,
            name: name,
            servingSize: servingSize,
            unit: unit,
            perServingCalories: perServingCalories,
            carbohydrates: carbohydrates,
            protein: protein,
            fat: fat,
            brand: brand,
            createdAt: createdAt
        )
    }
}

extension FoodSearchResult {
    static func fixture(
        totalItems: Int = 1,
        currentPage: Int = 0,
        itemsPerPage: Int = 20,
        totalPages: Int = 1,
        items: [FoodData] = [.fixture()]
    ) -> FoodSearchResult {
        FoodSearchResult(
            totalItems: totalItems,
            currentPage: currentPage,
            itemsPerPage: itemsPerPage,
            totalPages: totalPages,
            items: items
        )
    }
}
