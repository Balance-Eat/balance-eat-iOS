//
//  MockDietUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockDietUseCase: DietUseCaseProtocol {

    // MARK: - 반환값 설정
    var createDietResult: Result<Void, NetworkError> = .success(())
    var updateDietResult: Result<Void, NetworkError> = .success(())
    var deleteDietResult: Result<Void, NetworkError> = .success(())
    var getDailyDietResult: Result<[DietData], NetworkError> = .success([])
    var getMonthlyDietResult: Result<[DietData], NetworkError> = .success([])

    // MARK: - 호출 횟수 추적
    private(set) var createDietCallCount = 0
    private(set) var updateDietCallCount = 0
    private(set) var deleteDietCallCount = 0

    // MARK: - 전달된 인자 캡처
    private(set) var capturedCreateMealType: MealType?
    private(set) var capturedCreateConsumedAt: String?
    private(set) var capturedCreateDietFoods: [DietFoodRequest]?
    private(set) var capturedCreateUserId: String?

    private(set) var capturedUpdateDietId: Int?
    private(set) var capturedUpdateMealType: MealType?
    private(set) var capturedUpdateDietFoods: [DietFoodRequest]?

    private(set) var capturedDeleteDietId: Int?
    private(set) var capturedDeleteUserId: String?

    // MARK: - Protocol 구현

    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        createDietCallCount += 1
        capturedCreateMealType = mealType
        capturedCreateConsumedAt = consumedAt
        capturedCreateDietFoods = dietFoods
        capturedCreateUserId = userId
        return createDietResult
    }

    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [DietFoodRequest], userId: String) async -> Result<Void, NetworkError> {
        updateDietCallCount += 1
        capturedUpdateDietId = dietId
        capturedUpdateMealType = mealType
        capturedUpdateDietFoods = dietFoods
        return updateDietResult
    }

    func deleteDiet(dietId: Int, userId: String) async -> Result<Void, NetworkError> {
        deleteDietCallCount += 1
        capturedDeleteDietId = dietId
        capturedDeleteUserId = userId
        return deleteDietResult
    }

    func getDailyDiet(date: Date, userId: String) async -> Result<[DietData], NetworkError> {
        getDailyDietResult
    }

    func getMonthlyDiet(year: Int, month: Int, userId: String) async -> Result<[DietData], NetworkError> {
        getMonthlyDietResult
    }
}
