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
    case requestFailed(String, String)
    case timeout
    case noConnection
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case internalServerError

    public var userMessage: String {
        switch self {
        case .invalid:
            return "유효하지 않은 요청입니다."
        case .failToDecode:
            return "데이터 처리 중 오류가 발생했습니다."
        case .dataNil:
            return "데이터가 없습니다."
        case .serverError:
            return "서버 오류가 발생했습니다."
        case .requestFailed(_, let message):
            return message
        case .timeout:
            return "요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요."
        case .noConnection:
            return "인터넷 연결을 확인해주세요."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .forbidden:
            return "접근 권한이 없습니다."
        case .notFound:
            return "요청한 정보를 찾을 수 없습니다."
        case .rateLimited:
            return "잠시 후 다시 시도해주세요."
        case .internalServerError:
            return "서버 오류가 발생했습니다."
        }
    }

    public var developerMessage: String {
        switch self {
        case .invalid:
            return "Invalid request"
        case .failToDecode(let description):
            return "Decode failed: \(description)"
        case .dataNil:
            return "Response data is nil"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .requestFailed(let status, let message):
            return "Request failed - status: \(status), message: \(message)"
        case .timeout:
            return "Request timed out"
        case .noConnection:
            return "No internet connection"
        case .unauthorized:
            return "401 Unauthorized"
        case .forbidden:
            return "403 Forbidden"
        case .notFound:
            return "404 Not Found"
        case .rateLimited:
            return "429 Rate Limited"
        case .internalServerError:
            return "500+ Internal Server Error"
        }
    }

    public var description: String {
        userMessage
    }
}
