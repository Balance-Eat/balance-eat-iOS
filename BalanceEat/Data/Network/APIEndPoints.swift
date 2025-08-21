//
//  APIEndPoints.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import Alamofire

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var queryParameters: [String: Any]? { get }
}

enum UserEndPoints: Endpoint {

    case createUser(createUserDTO: CreateUserDTO)
    case getUser(uuid: String)
    
    var path: String {
        switch self {
        case .createUser:
            return "/v1/users"
        case .getUser:
            return "/v1/users/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createUser:
                .post
        case .getUser:
                .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .createUser(let createUserDTO):
            return [
                "uuid": createUserDTO.uuid,
                "name": createUserDTO.name,
                "gender": createUserDTO.gender.rawValue,
                "age": createUserDTO.age,
                "height": createUserDTO.height,
                "weight": createUserDTO.weight,
                "email": createUserDTO.email,
                "activityLevel": createUserDTO.activityLevel.rawValue,
                "smi": createUserDTO.smi,
                "fatPercentage": createUserDTO.fatPercentage,
                "targetWeight": createUserDTO.targetWeight,
                "targetCalorie": createUserDTO.targetCalorie,
                "targetSmi": createUserDTO.targetSmi,
                "targetFatPercentage": createUserDTO.targetFatPercentage,
                "providerId": createUserDTO.providerId,
                "providerType": createUserDTO.providerType
            ]
        case .getUser:
            return nil
        }
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .getUser(let uuid):
            return ["uuid": uuid]
        default:
            return nil
        }
    }
}
