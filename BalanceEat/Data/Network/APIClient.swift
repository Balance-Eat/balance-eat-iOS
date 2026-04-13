//
//  APIClient.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
@preconcurrency import Alamofire

private struct ErrorResponse: Decodable {
    let message: String
    let status: String
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private init() {}

    private static let decoder = JSONDecoder()

    private let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return Session(configuration: configuration)
    }()

    private let baseURL = "https://api.balance-eat.com"

    func request<T: Decodable>(
        endpoint: any Endpoint,
        responseType: T.Type
    ) async -> Result<T, NetworkError> {
        let url = baseURL + endpoint.path
        #if DEBUG
        let debugHeaders = endpoint.headers?.description ?? ""
        let debugQueryParameters = String(describing: endpoint.queryParameters ?? [:])
        #endif

        let dataRequest = buildDataRequest(endpoint: endpoint)

        return await withCheckedContinuation { continuation in
            dataRequest
                .validate()
                .responseDecodable(of: T.self) { [self] response in
                    switch response.result {
                    case .success(let value):
                        #if DEBUG
                        let statusCode = response.response?.statusCode
                        let responseData = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"
                        print("""
                            🅾️ API Request Success
                            - URL: \(url)
                            - Status Code: \(statusCode ?? 0)
                            - Response Body: \(responseData)
                            - value: \(value)
                            """)
                        #endif
                        continuation.resume(returning: .success(value))

                    case .failure(let afError):
                        let (statusMessage, serverMessage) = self.parseServerError(from: response.data, fallbackMessage: afError.localizedDescription)

                        #if DEBUG
                        let statusCode = response.response?.statusCode
                        let responseDataString = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"
                        print("""
                            ❌ API Request Failed
                            - URL: \(url)
                            - Status Code: \(statusCode ?? 0)
                            - Error: \(serverMessage)
                            - Response Body: \(responseDataString)
                            - afError: \(afError.localizedDescription)
                            - headers: \(debugHeaders)
                            """)
                        print("query parameters: \(debugQueryParameters)")
                        #endif

                        let networkError = self.mapToNetworkError(afError: afError, statusCode: response.response?.statusCode, statusMessage: statusMessage, serverMessage: serverMessage)
                        continuation.resume(returning: .failure(networkError))
                    }
                }
        }
    }

    func requestVoid(endpoint: any Endpoint) async -> Result<Void, NetworkError> {
        let dataRequest = buildDataRequest(endpoint: endpoint)

        return await withCheckedContinuation { continuation in
            dataRequest
                .validate()
                .response { [self] response in
                    let statusCode = response.response?.statusCode ?? 0

                    if (200..<300).contains(statusCode) {
                        #if DEBUG
                        print("🅾️ API Request Success (Void)")
                        #endif
                        continuation.resume(returning: .success(()))
                    } else {
                        let fallbackMessage = response.error?.localizedDescription ?? "알 수 없는 오류"
                        let (statusMessage, serverMessage) = self.parseServerError(from: response.data, fallbackMessage: fallbackMessage)
                        let networkError = self.mapToNetworkError(afError: response.error, statusCode: statusCode, statusMessage: statusMessage, serverMessage: serverMessage)
                        continuation.resume(returning: .failure(networkError))
                    }
                }
        }
    }
}

// MARK: - Private

private extension APIClient {
    func buildDataRequest(endpoint: any Endpoint) -> DataRequest {
        let url = baseURL + endpoint.path
        if let body = endpoint.body {
            return session.request(
                url,
                method: endpoint.method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: endpoint.headers
            )
        } else {
            return session.request(
                url,
                method: endpoint.method,
                parameters: endpoint.queryParameters,
                encoding: URLEncoding.default,
                headers: endpoint.headers
            )
        }
    }

    func parseServerError(from data: Data?, fallbackMessage: String) -> (status: String, message: String) {
        guard let data else { return ("Unknown Error", fallbackMessage) }

        if let apiError = try? Self.decoder.decode(BaseResponse<EmptyData>.self, from: data) {
            return (apiError.status, apiError.message)
        } else if let errorResponse = try? Self.decoder.decode(ErrorResponse.self, from: data) {
            return (errorResponse.status, errorResponse.message)
        }

        return ("Unknown Error", fallbackMessage)
    }

    func mapToNetworkError(afError: AFError?, statusCode: Int?, statusMessage: String, serverMessage: String) -> NetworkError {
        if let urlError = afError?.underlyingError as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                return .noConnection
            default:
                return .requestFailed(statusMessage, serverMessage)
            }
        }

        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 409: return .conflict
        case 429: return .rateLimited
        case let code where (code ?? 0) >= 500: return .internalServerError
        default: return .requestFailed(statusMessage, serverMessage)
        }
    }
}
