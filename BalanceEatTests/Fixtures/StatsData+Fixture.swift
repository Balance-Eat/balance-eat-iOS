//
//  StatsData+Fixture.swift
//  BalanceEatTests
//

@testable import BalanceEat

extension StatsData {
    static func fixture(
        type: Period = .daily,
        date: String = "2026-03-12",
        totalCalories: Double = 2000,
        totalCarbohydrates: Double = 300,
        totalProtein: Double = 150,
        totalFat: Double = 60
    ) -> StatsData {
        StatsData(
            type: type,
            date: date,
            totalCalories: totalCalories,
            totalCarbohydrates: totalCarbohydrates,
            totalProtein: totalProtein,
            totalFat: totalFat
        )
    }
}
