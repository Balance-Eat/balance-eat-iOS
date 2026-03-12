//
//  UserData+Fixture.swift
//  BalanceEatTests
//

@testable import BalanceEat

extension UserData {
    static func fixture(
        id: Int = 1,
        uuid: String = "test-uuid",
        name: String = "테스트유저",
        email: String? = nil,
        gender: Gender = .male,
        age: Int = 25,
        weight: Double = 70.0,
        height: Double = 175.0,
        goalType: GoalType = .maintain,
        activityLevel: ActivityLevel = .moderate,
        smi: Double? = nil,
        fatPercentage: Double? = nil,
        targetWeight: Double = 68.0,
        targetCalorie: Double = 2000.0
    ) -> UserData {
        UserData(
            id: id,
            uuid: uuid,
            name: name,
            email: email,
            gender: gender,
            age: age,
            weight: weight,
            height: height,
            goalType: goalType,
            activityLevel: activityLevel,
            smi: smi,
            fatPercentage: fatPercentage,
            targetWeight: targetWeight,
            targetCalorie: targetCalorie,
            targetSmi: nil,
            targetFatPercentage: nil,
            targetCarbohydrates: nil,
            targetProtein: nil,
            targetFat: nil,
            providerId: nil,
            providerType: nil
        )
    }
}

extension DietFoodData {
    static func fixture(
        id: Int = 1,
        name: String = "닭가슴살",
        intake: Double = 100,
        servingSize: Double = 100,
        unit: String = "g",
        calories: Double = 165,
        carbohydrates: Double = 0,
        protein: Double = 31,
        fat: Double = 3.6
    ) -> DietFoodData {
        DietFoodData(
            id: id,
            name: name,
            intake: intake,
            servingSize: servingSize,
            unit: unit,
            calories: calories,
            carbohydrates: carbohydrates,
            protein: protein,
            fat: fat
        )
    }
}

extension DietData {
    static func fixture(
        id: Int = 1,
        consumeDate: String = "2026-03-12",
        consumedAt: String = "2026-03-12T08:00:00",
        mealType: MealType = .breakfast,
        items: [DietFoodData] = []
    ) -> DietData {
        DietData(
            id: id,
            consumeDate: consumeDate,
            consumedAt: consumedAt,
            mealType: mealType,
            items: items
        )
    }
}
