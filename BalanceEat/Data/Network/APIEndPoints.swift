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

enum ReminderEndPoints: Endpoint {
    case getReminderList(userId: String)
    case createReminder(reminderRequestDTO: ReminderRequestDTO, userId: String)
    case getReminderDetail(reminderId: Int, userId: String)
    case updateReminder(reminderRequestDTO: ReminderRequestDTO, reminderId: Int, userId: String)
    case deleteReminder(reminderId: Int, userId: String)
    case updateReminderActivation(isActive: Bool, reminderId: Int, userId: String)
    
    var path: String {
        switch self {
        case .getReminderList:
            return "/v1/reminders"
        case .createReminder:
            return "/v1/reminders"
        case .getReminderDetail(let reminderId, _):
            return "/v1/reminders/\(reminderId)"
        case .updateReminder(_, let reminderId, _):
            return "/v1/reminders/\(reminderId)"
        case .deleteReminder(let reminderId, _):
            return "/v1/reminders/\(reminderId)"
        case .updateReminderActivation(_, let reminderId, _):
            return "/v1/reminders/\(reminderId)/activation"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getReminderList, .getReminderDetail:
            return .get
        case .createReminder:
            return .post
        case .updateReminder:
            return .put
        case .deleteReminder:
            return .delete
        case .updateReminderActivation:
            return .patch
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        case .createReminder(let reminderRequestDTO, _), .updateReminder(let reminderRequestDTO, _, _):
            return [
                "content": reminderRequestDTO.content,
                "sendTime": reminderRequestDTO.sendTime,
                "isActive": reminderRequestDTO.isActive,
                "dayOfWeeks": reminderRequestDTO.dayOfWeeks
            ]
        case .updateReminderActivation(let isActive, _, _):
            return [
                "isActive": isActive
            ]
        default:
            return nil
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var headers: Alamofire.HTTPHeaders? {
        switch self {
        case .getReminderList(let userId), .createReminder(_, let userId), .getReminderDetail(_, let userId), .updateReminder(_, _, let userId), .deleteReminder(_, let userId), .updateReminderActivation(_, _, let userId):
            return ["X-USER-ID": userId]
        }
    }
    
    
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
    case createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String)
    case updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String)
    case deleteDiet(dietId: Int, userId: String)
    case daily(date: String, userId: String)
    case monthly(yearMonth: String, userId: String)
    
    var path: String {
        switch self {
        case .createDiet:
            return "/v1/diets"
        case .updateDiet(let dietId, _, _, _, _), .deleteDiet(let dietId, _):
            return "/v1/diets/\(dietId)"
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
        case .updateDiet:
            return .put
        case .deleteDiet:
            return .delete
        case .daily:
            return .get
        case .monthly:
            return .get
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        case .createDiet(let mealType, let consumedAt, let dietFoods, _):
            return [
                "mealType": mealType.rawValue,
                "consumedAt": consumedAt,
                "dietFoods": dietFoods.map { $0.toDictionary() }
            ]
        case .updateDiet(_, let mealType, let consumedAt, let dietFoods, _):
            return [
                "mealType": mealType.rawValue,
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
        case .createDiet(_, _, _, let userId), .updateDiet(_, _, _, _, let userId), .deleteDiet(_, let userId), .daily(_, let userId), .monthly(_, let userId):
            return ["X-USER-ID": userId]
        }
    }
}

enum NotificationEndpoints: Endpoint {
    case create(notificationRequestDTO: NotificationRequestDTO, userId: String)
    case updateActivation(isActive: Bool, deviceId: Int, userId: String)
    case getCurrentDevice(userId: String, agentId: String)
    
    var path: String {
        switch self {
        case .create:
            return "/v1/notification-devices"
        case .updateActivation(_, let deviceId, _):
            return "/v1/notification-devices/\(deviceId)/activation"
        case .getCurrentDevice:
            return "/v1/notification-devices/current"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .create:
            return .post
        case .updateActivation:
            return .patch
        case .getCurrentDevice:
            return .get
        }
    }
    
    var parameters: [String : Any?]? {
        switch self {
        case .create(let notificationRequestDTO, _):
            return [
                "agentId": notificationRequestDTO.agentId,
                "osType": notificationRequestDTO.osType,
                "deviceName": notificationRequestDTO.deviceName,
                "isActive": notificationRequestDTO.isActive
            ]
        case .updateActivation(let isActive, _, _):
            return [
                "isActive": isActive
            ]
        default:
            return nil
        }
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var headers: Alamofire.HTTPHeaders? {
        switch self {
        case .create(_, let userId), .updateActivation(_, _, let userId):
            return ["X-USER-ID": userId]
        case .getCurrentDevice(let userId, let agentId):
            return [
                "X-USER-ID": userId,
                "X-Device-Agent-Id": agentId
            ]
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

enum StatsEndPoints: Endpoint {
    case getStats(period: Period, userId: String)
    
    var path: String {
        switch self {
        case .getStats:
            "/v1/stats"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getStats:
            .get
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
        case .getStats(let period, _):
            return ["type": period.rawValue]
        }
    }
    
    var headers: Alamofire.HTTPHeaders? {
        switch self {
        case .getStats(_, let userId):
            return ["X-USER-ID": userId]
        }
    }
}
