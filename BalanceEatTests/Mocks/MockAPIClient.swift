//
//  MockAPIClient.swift
//  BalanceEatTests
//

import Foundation
@testable import BalanceEat

final class MockAPIClient: APIClientProtocol {
    var requestResult: Any = ()
    var requestVoidResult: Result<Void, NetworkError> = .success(())

    private(set) var requestCallCount = 0
    private(set) var requestVoidCallCount = 0
    private(set) var capturedEndpointPath: String?

    func request<T: Decodable>(endpoint: any Endpoint, responseType: T.Type) async -> Result<T, NetworkError> {
        requestCallCount += 1
        capturedEndpointPath = endpoint.path
        if let result = requestResult as? Result<T, NetworkError> {
            return result
        }
        fatalError("MockAPIClient.requestResult 타입이 \(T.self)와 일치하지 않습니다.")
    }

    func requestVoid(endpoint: any Endpoint) async -> Result<Void, NetworkError> {
        requestVoidCallCount += 1
        capturedEndpointPath = endpoint.path
        return requestVoidResult
    }
}
