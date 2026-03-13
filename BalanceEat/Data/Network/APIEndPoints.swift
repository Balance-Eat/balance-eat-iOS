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
    var body: AnyEncodable? { get }
    var queryParameters: [String: Any]? { get }
    var headers: HTTPHeaders? { get }
}

extension Endpoint {
    var body: AnyEncodable? { nil }
    var queryParameters: [String: Any]? { nil }
}

// MARK: - 공용 request body

private struct IsActiveRequestBody: Encodable {
    let isActive: Bool
}

// MARK: - ReminderEndPoints

enum ReminderEndPoints: Endpoint {
    case getReminderList(page: Int, size: Int, userId: String)
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

    var method: HTTPMethod {
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

    var body: AnyEncodable? {
        switch self {
        case .createReminder(let dto, _), .updateReminder(let dto, _, _):
            return AnyEncodable(dto)
        case .updateReminderActivation(let isActive, _, _):
            return AnyEncodable(IsActiveRequestBody(isActive: isActive))
        default:
            return nil
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .getReminderList(let page, let size, _):
            return ["page": page, "size": size]
        default:
            return nil
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .getReminderList(_, _, let userId),
             .createReminder(_, let userId),
             .getReminderDetail(_, let userId),
             .updateReminder(_, _, let userId),
             .deleteReminder(_, let userId),
             .updateReminderActivation(_, _, let userId):
            return ["X-USER-ID": userId]
        }
    }
}

// MARK: - UserEndPoints

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
        case .createUser: .post
        case .updateUser: .put
        case .getUser:    .get
        }
    }

    var body: AnyEncodable? {
        switch self {
        case .createUser(let userDTO), .updateUser(let userDTO):
            return AnyEncodable(userDTO)
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

    var headers: HTTPHeaders? { nil }
}

// MARK: - DietEndPoints

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

    var method: HTTPMethod {
        switch self {
        case .createDiet:  return .post
        case .updateDiet:  return .put
        case .deleteDiet:  return .delete
        case .daily:       return .get
        case .monthly:     return .get
        }
    }

    var body: AnyEncodable? {
        switch self {
        case .createDiet(let mealType, let consumedAt, let dietFoods, _),
             .updateDiet(_, let mealType, let consumedAt, let dietFoods, _):
            return AnyEncodable(CreateDietRequestBody(
                mealType: mealType.rawValue,
                consumedAt: consumedAt,
                dietFoods: dietFoods
            ))
        default:
            return nil
        }
    }

    var queryParameters: [String: Any]? {
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
        case .createDiet(_, _, _, let userId),
             .updateDiet(_, _, _, _, let userId),
             .deleteDiet(_, let userId),
             .daily(_, let userId),
             .monthly(_, let userId):
            return ["X-USER-ID": userId]
        }
    }
}

// MARK: - NotificationEndpoints

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

    var method: HTTPMethod {
        switch self {
        case .create:           return .post
        case .updateActivation: return .patch
        case .getCurrentDevice: return .get
        }
    }

    var body: AnyEncodable? {
        switch self {
        case .create(let dto, _):
            return AnyEncodable(dto)
        case .updateActivation(let isActive, _, _):
            return AnyEncodable(IsActiveRequestBody(isActive: isActive))
        default:
            return nil
        }
    }

    var headers: HTTPHeaders? {
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

// MARK: - FoodEndPoints

enum FoodEndPoints: Endpoint {
    case create(createFoodDTO: CreateFoodDTO)
    case search(foodName: String, page: Int, size: Int)

    var path: String {
        switch self {
        case .create:  return "/v1/foods"
        case .search:  return "/v1/foods/search"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .create: return .post
        case .search: return .get
        }
    }

    var body: AnyEncodable? {
        switch self {
        case .create(let dto):
            return AnyEncodable(dto)
        default:
            return nil
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .search(let foodName, let page, let size):
            return ["foodName": foodName, "page": page, "size": size]
        default:
            return nil
        }
    }

    var headers: HTTPHeaders? { nil }
}

// MARK: - StatsEndPoints

enum StatsEndPoints: Endpoint {
    case getStats(period: Period, userId: String)

    var path: String {
        switch self {
        case .getStats: "/v1/stats"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getStats: .get
        }
    }

    var queryParameters: [String: Any]? {
        switch self {
        case .getStats(let period, _):
            return ["type": period.rawValue]
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .getStats(_, let userId):
            return ["X-USER-ID": userId]
        }
    }
}
