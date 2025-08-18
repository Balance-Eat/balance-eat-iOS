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
                       parameters: endpoint.parameters,
                       encoding: (endpoint.method == .get ? URLEncoding.default : JSONEncoding.default))
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: .success(value))
                case .failure(let afError):
                    continuation.resume(returning: .failure(.requestFailed(afError.localizedDescription)))
                }
            }
        }
    }
}
