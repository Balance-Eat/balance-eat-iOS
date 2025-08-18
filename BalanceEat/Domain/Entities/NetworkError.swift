//
//  NetworkError.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

public enum NetworkError: Error {
    case invalid
    case failToDecode(String)
    case dataNil
    case serverError(Int)
    case requestFailed(String)
    
    public var description: String {
        switch self {
        case .invalid:
            "유효하지 않은 요청입니다."
        case .failToDecode(let description):
            "디코딩 에러 \(description)"
        case .dataNil:
            "데이터가 없습니다."
        case .serverError(let statusCode):
            "서버 에러 \(statusCode)"
        case .requestFailed(let message):
            "서버 요청 실패 \(message)"
        }
    }
}
