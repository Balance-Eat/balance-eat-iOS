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
        guard let result = requestResult as? Result<T, NetworkError> else {
            return .failure(.invalid)
        }
        return result
    }

    func requestVoid(endpoint: any Endpoint) async -> Result<Void, NetworkError> {
        requestVoidCallCount += 1
        capturedEndpointPath = endpoint.path
        return requestVoidResult
    }
}
