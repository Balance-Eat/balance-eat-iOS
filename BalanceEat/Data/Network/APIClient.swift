//
//  APIClient.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
@preconcurrency import Alamofire

final class APIClient {
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
        endpoint: Endpoint,
        responseType: T.Type
    ) async -> Result<T, NetworkError> {
        let url = baseURL + endpoint.path
        #if DEBUG
        let debugHeaders = endpoint.headers?.description ?? ""
        let debugQueryParameters = String(describing: endpoint.queryParameters ?? [:])
        #endif

        let dataRequest: DataRequest
        if let body = endpoint.body {
            dataRequest = session.request(
                url,
                method: endpoint.method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: endpoint.headers
            )
        } else {
            dataRequest = session.request(
                url,
                method: endpoint.method,
                parameters: endpoint.queryParameters,
                encoding: URLEncoding.default,
                headers: endpoint.headers
            )
        }

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
                            } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                      let message = json["message"] as? String,
                                      let status = json["status"] as? String {
                                statusMessage = status
                                serverMessage = message
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
                        continuation.resume(returning: .failure(.requestFailed(statusMessage, serverMessage)))
                    }
                }
        }
    }

    func requestVoid(endpoint: Endpoint) async -> Result<Void, NetworkError> {
        let url = baseURL + endpoint.path

        let dataRequest: DataRequest
        if let body = endpoint.body {
            dataRequest = session.request(
                url,
                method: endpoint.method,
                parameters: body,
                encoder: JSONParameterEncoder.default,
                headers: endpoint.headers
            )
        } else {
            dataRequest = session.request(
                url,
                method: endpoint.method,
                parameters: endpoint.queryParameters,
                encoding: URLEncoding.default,
                headers: endpoint.headers
            )
        }

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
                        } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                  let message = json["message"] as? String,
                                  let status = json["status"] as? String {
                            statusMessage = status
                            serverMessage = message
                        }
                    }

                    if (200..<300).contains(statusCode) {
                        #if DEBUG
                        print("🅾️ API Request Success (Void)")
                        #endif
                        continuation.resume(returning: .success(()))
                    } else {
                        continuation.resume(returning: .failure(.requestFailed(statusMessage, serverMessage)))
                    }
                }
        }
    }
}
