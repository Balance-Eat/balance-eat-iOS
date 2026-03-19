//
//  MockNotificationUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockNotificationUseCase: NotificationUseCaseProtocol {

    var createNotificationResult: Result<NotificationData, NetworkError> = .success(.fixture())
    var updateActivationResult: Result<NotificationData, NetworkError> = .success(.fixture())
    var getCurrentDeviceResult: Result<NotificationData, NetworkError> = .success(.fixture())

    func createNotification(request: NotificationCreateRequest, userId: String) async -> Result<NotificationData, NetworkError> {
        createNotificationResult
    }

    func updateActivation(isActive: Bool, deviceId: Int, userId: String) async -> Result<NotificationData, NetworkError> {
        updateActivationResult
    }

    func getCurrentDevice(userId: String, agentId: String) async -> Result<NotificationData, NetworkError> {
        getCurrentDeviceResult
    }
}
