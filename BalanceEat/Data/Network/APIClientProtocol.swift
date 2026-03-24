//
//  APIClientProtocol.swift
//  BalanceEat
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: any Endpoint, responseType: T.Type) async -> Result<T, NetworkError>
    func requestVoid(endpoint: any Endpoint) async -> Result<Void, NetworkError>
}
