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
}

enum UserEndPoints: Endpoint {
    case createUser(createUserDTO: CreateUserDTO)
    
    var path: String {
        switch self {
        case .createUser:
            return "/api/v1/users"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createUser:
                .post
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
        }
    }
}
