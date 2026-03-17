//
//  MockStatsUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockStatsUseCase: StatsUseCaseProtocol {

    var getStatsResult: Result<[StatsData], NetworkError> = .success([])

    private(set) var getStatsCallCount = 0
    private(set) var capturedPeriod: Period?

    func getStats(period: Period, userId: String) async -> Result<[StatsData], NetworkError> {
        getStatsCallCount += 1
        capturedPeriod = period
        return getStatsResult
    }
}
