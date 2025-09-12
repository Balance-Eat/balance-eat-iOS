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
    var parameters: [String: Any?]? { get }
    var queryParameters: [String: Any]? { get }
}

enum UserEndPoints: Endpoint {

    case createUser(userDTO: UserDTO)
    case updateUser(userDTO: UserDTO)
    case getUser(uuid: String)
    
    var path: String {
        switch self {
        case .createUser:
            return "/v1/users"
        case .updateUser(let userDTO):
            return "/v1/users/\(userDTO.id ?? 0)"
        case .getUser:
            return "/v1/users/me"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createUser:
                .post
        case .updateUser:
                .put
        case .getUser:
                .get
        }
    }
    
    var parameters: [String: Any?]? {
        switch self {
        case .createUser(let userDTO):
            return [
                "uuid": userDTO.uuid,
                "name": userDTO.name,
                "gender": userDTO.gender.rawValue,
                "age": userDTO.age,
                "height": userDTO.height,
                "weight": userDTO.weight,
                "email": userDTO.email,
                "activityLevel": userDTO.activityLevel?.rawValue,
                "smi": userDTO.smi,
                "fatPercentage": userDTO.fatPercentage,
                "targetWeight": userDTO.targetWeight,
                "targetCalorie": userDTO.targetCalorie,
                "targetSmi": userDTO.targetSmi,
                "targetFatPercentage": userDTO.targetFatPercentage,
                "targetCarbohydrates": userDTO.targetCarbohydrates,
                "targetProtein": userDTO.targetProtein,
                "targetFat": userDTO.targetFat,
                "providerId": userDTO.providerId,
                "providerType": userDTO.providerType
            ]
        case .updateUser(let userDTO):
            return [
                "name": userDTO.name,
                "email": userDTO.email,
                "gender": userDTO.gender.rawValue,
                "age": userDTO.age,
                "height": userDTO.height,
                "weight": userDTO.weight,
                "activityLevel": userDTO.activityLevel?.rawValue,
                "smi": userDTO.smi,
                "fatPercentage": userDTO.fatPercentage,
                "targetWeight": userDTO.targetWeight,
                "targetCalorie": userDTO.targetCalorie,
                "targetSmi": userDTO.targetSmi,
                "targetFatPercentage": userDTO.targetFatPercentage,
                "targetCarbohydrates": userDTO.targetCarbohydrates,
                "targetProtein": userDTO.targetProtein,
                "targetFat": userDTO.targetFat
            ]
        default:
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

enum DietEndPoints: Endpoint {
    case daily(date: String)
    
    var path: String {
        switch self {
        case .daily:
            return "/v1/diets/daily"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .daily:
            return .get
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        default:
            return nil
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .daily(let date):
            return ["date": date]
        }
    }
    
    
}
