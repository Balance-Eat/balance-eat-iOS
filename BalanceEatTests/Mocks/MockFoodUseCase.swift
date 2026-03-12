//
//  MockFoodUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockFoodUseCase: FoodUseCaseProtocol {

    // MARK: - 반환값 설정
    var searchFoodResult: Result<FoodSearchResult, NetworkError> = .success(.fixture())
    var createFoodResult: Result<FoodData, NetworkError> = .success(.fixture())

    // MARK: - 호출 횟수 추적
    private(set) var searchFoodCallCount = 0
    private(set) var createFoodCallCount = 0

    // MARK: - 전달된 인자 캡처
    private(set) var capturedSearchFoodName: String?
    private(set) var capturedSearchPage: Int?
    private(set) var capturedSearchSize: Int?

    // MARK: - Protocol 구현

    func searchFood(foodName: String, page: Int, size: Int) async -> Result<FoodSearchResult, NetworkError> {
        searchFoodCallCount += 1
        capturedSearchFoodName = foodName
        capturedSearchPage = page
        capturedSearchSize = size
        return searchFoodResult
    }

    func createFood(createFoodDTO: CreateFoodDTO) async -> Result<FoodData, NetworkError> {
        createFoodCallCount += 1
        return createFoodResult
    }
}
