//
//  APIClient.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import Alamofire

final class APIClient {
    static let shared = APIClient()
    private init() {}
    
    private let baseURL = "https://api.balance-eat.com"
    
    func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async -> Result<T, NetworkError> {
        let url = baseURL + endpoint.path
        
        
        return await withCheckedContinuation { continuation in
            AF.request(url,
                       method: endpoint.method,
                       parameters: endpoint.method == .get ? endpoint.queryParameters : endpoint.parameters,
                       encoding: (endpoint.method == .get ? URLEncoding.default : JSONEncoding.default),
                       headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    let statusCode = response.response?.statusCode
                    let responseData = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"
                    
                    let message = """
                                    🅾️ API Request Success
                                    - URL: \(url)
                                    - Status Code: \(statusCode ?? 0)
                                    - Response Body: \(responseData)
                                    - value: \(value)
                                    """
                    
                    print(message)
                    continuation.resume(returning: .success(value))
                case .failure(let afError):
                    let statusCode = response.response?.statusCode
                    let responseDataString = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "No Body"
                    
                    var serverMessage = afError.localizedDescription
                    
                    if let data = response.data {
                        if let apiError = try? JSONDecoder().decode(BaseResponse<EmptyData>.self, from: data) {
                            serverMessage = apiError.message
                        }
                    }
                    
                    let errorMessage = """
                                        ❌ API Request Failed
                                        - URL: \(url)
                                        - Status Code: \(statusCode ?? 0)
                                        - Error: \(serverMessage)
                                        - Response Body: \(responseDataString)
                                        - afError: \(afError.localizedDescription)
                                        """
                    
                    print(errorMessage)
                    print("parameters: \(endpoint.parameters ?? [:])")
                    continuation.resume(returning: .failure(.requestFailed(serverMessage)))
                }
            }
        }
    }
}
