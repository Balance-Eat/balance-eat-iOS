//
//  UserDefaultsManager.swift
//  BalanceEat
//
//  Created by 김견 on 11/21/25.
//

import Foundation

enum UserDefaultsKey: String {
    case pushNotificationEnabled = "pushNotificationEnabled"
    case saveToNotificationServerSuccess = "saveToNotificationServerSuccess"
    case agentId = "agentId"
}

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    //MARK: - Bool 값
    func set(_ value: Bool, forKey key: UserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func getBool(forKey key: UserDefaultsKey, defaultValue: Bool = false) -> Bool {
        if defaults.object(forKey: key.rawValue) == nil {
            return defaultValue
        }
        return defaults.bool(forKey: key.rawValue)
    }
    
    // MARK: - Int 값
    func set(_ value: Int, forKey key: UserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func getInt(forKey key: UserDefaultsKey, defaultValue: Int = 0) -> Int {
        if defaults.object(forKey: key.rawValue) == nil {
            return defaultValue
        }
        return defaults.integer(forKey: key.rawValue)
    }
    
    // MARK: - String 값
    func set(_ value: String, forKey key: UserDefaultsKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func getString(forKey key: UserDefaultsKey, defaultValue: String = "") -> String {
        return defaults.string(forKey: key.rawValue) ?? defaultValue
    }
    
    // MARK: - 값 삭제
    func removeValue(forKey key: UserDefaultsKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
