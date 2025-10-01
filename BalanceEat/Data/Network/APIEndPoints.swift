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
    var headers: HTTPHeaders? { get }
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
                "goalType": userDTO.goalType.title,
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
                "goalType": userDTO.goalType.rawValue,
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
    
    var headers: HTTPHeaders? {
        switch self {
        default:
            return nil
        }
    }
}

enum DietEndPoints: Endpoint {
    case createDiet(mealTime: MealTime, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String)
    case daily(date: String, userId: String)
    case monthly(yearMonth: String, userId: String)
    
    var path: String {
        switch self {
        case .createDiet:
            return "/v1/diets"
        case .daily:
            return "/v1/diets/daily"
        case .monthly:
            return "/v1/diets/monthly"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .createDiet:
            return .post
        case .daily:
            return .get
        case .monthly:
            return .get
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        case .createDiet(let mealTime, let consumedAt, let dietFoods, _):
            return [
                "mealType": mealTime.title,
                "consumedAt": consumedAt,
                "dietFoods": dietFoods.map { $0.toDictionary() }
            ]
        default:
            return nil
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .daily(let date, _):
            return ["date": date]
        case .monthly(let yearMonth, _):
            return ["yearMonth": yearMonth]
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .daily(_, let userId), .createDiet(_, _, _, let userId), .monthly(_, let userId):
            return ["X-USER-ID": userId]
        }
    }
}

enum FoodEndPoints: Endpoint {
    case create(createFoodDTO: CreateFoodDTO)
    case search(foodName: String, page: Int, size: Int)
    
    var path: String {
        switch self {
        case .create:
            return "/v1/foods"
        case .search:
            return "/v1/foods/search"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .create:
            return .post
        case .search:
            return .get
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        case .create(let foodDTO):
            return [
                "uuid": foodDTO.uuid,
                "name": foodDTO.name,
                "servingSize": foodDTO.servingSize,
                "unit": foodDTO.unit,
                "carbohydrates": foodDTO.carbohydrates,
                "protein": foodDTO.protein,
                "fat": foodDTO.fat,
                "brand": foodDTO.brand
            ]
        default:
            return nil
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .search(let foodName, let page, let size):
            return [
                "foodName": foodName,
                "page": page,
                "size": size
            ]
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        default:
            return nil
        }
    }
}
