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

    private func buildDataRequest(endpoint: any Endpoint) -> DataRequest {
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
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        let statusCode = response.response?.statusCode
                        let responseData = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"

                        #if DEBUG
                        let message = """
                                        🅾️ API Request Success
                                        - URL: \(url)
                                        - Status Code: \(statusCode ?? 0)
                                        - Response Body: \(responseData)
                                        - value: \(value)
                                        """
                        print(message)
                        #endif
                        continuation.resume(returning: .success(value))

                    case .failure(let afError):
                        let statusCode = response.response?.statusCode
                        let responseDataString = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"

                        var statusMessage = "Unknown Error"
                        var serverMessage = afError.localizedDescription

                        if let data = response.data {
                            if let apiError = try? Self.decoder.decode(BaseResponse<EmptyData>.self, from: data) {
                                statusMessage = apiError.status
                                serverMessage = apiError.message
                            } else if let errorResponse = try? Self.decoder.decode(ErrorResponse.self, from: data) {
                                statusMessage = errorResponse.status
                                serverMessage = errorResponse.message
                            }
                        }

                        #if DEBUG
                        let errorMessage = """
                                            ❌ API Request Failed
                                            - URL: \(url)
                                            - Status Code: \(statusCode ?? 0)
                                            - Error: \(serverMessage)
                                            - Response Body: \(responseDataString)
                                            - afError: \(afError.localizedDescription)
                                            - headers: \(debugHeaders)
                                            """
                        print(errorMessage)
                        print("query parameters: \(debugQueryParameters)")
                        #endif

                        let networkError: NetworkError
                        if let urlError = afError.underlyingError as? URLError {
                            switch urlError.code {
                            case .timedOut:
                                networkError = .timeout
                            case .notConnectedToInternet, .networkConnectionLost:
                                networkError = .noConnection
                            default:
                                networkError = .requestFailed(statusMessage, serverMessage)
                            }
                        } else {
                            switch statusCode {
                            case 401:
                                networkError = .unauthorized
                            case 403:
                                networkError = .forbidden
                            case 404:
                                networkError = .notFound
                            case 429:
                                networkError = .rateLimited
                            case let code where (code ?? 0) >= 500:
                                networkError = .internalServerError
                            default:
                                networkError = .requestFailed(statusMessage, serverMessage)
                            }
                        }
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
                .response { response in
                    let statusCode = response.response?.statusCode ?? 0

                    var statusMessage = "Unknown Error"
                    var serverMessage = response.error?.localizedDescription ?? "알 수 없는 오류"

                    if let data = response.data {
                        if let apiError = try? Self.decoder.decode(BaseResponse<EmptyData>.self, from: data) {
                            statusMessage = apiError.status
                            serverMessage = apiError.message
                        } else if let errorResponse = try? Self.decoder.decode(ErrorResponse.self, from: data) {
                            statusMessage = errorResponse.status
                            serverMessage = errorResponse.message
                        }
                    }

                    if (200..<300).contains(statusCode) {
                        #if DEBUG
                        print("🅾️ API Request Success (Void)")
                        #endif
                        continuation.resume(returning: .success(()))
                    } else {
                        let networkError: NetworkError
                        if let afError = response.error {
                            if let urlError = afError.underlyingError as? URLError {
                                switch urlError.code {
                                case .timedOut:
                                    networkError = .timeout
                                case .notConnectedToInternet, .networkConnectionLost:
                                    networkError = .noConnection
                                default:
                                    networkError = .requestFailed(statusMessage, serverMessage)
                                }
                            } else {
                                switch statusCode {
                                case 401:
                                    networkError = .unauthorized
                                case 403:
                                    networkError = .forbidden
                                case 404:
                                    networkError = .notFound
                                case 429:
                                    networkError = .rateLimited
                                case 500...:
                                    networkError = .internalServerError
                                default:
                                    networkError = .requestFailed(statusMessage, serverMessage)
                                }
                            }
                        } else {
                            switch statusCode {
                            case 401:
                                networkError = .unauthorized
                            case 403:
                                networkError = .forbidden
                            case 404:
                                networkError = .notFound
                            case 429:
                                networkError = .rateLimited
                            case 500...:
                                networkError = .internalServerError
                            default:
                                networkError = .requestFailed(statusMessage, serverMessage)
                            }
                        }
                        continuation.resume(returning: .failure(networkError))
                    }
                }
        }
    }
}
