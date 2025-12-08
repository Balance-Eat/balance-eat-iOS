//
//  ReminderData.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderData {
    let id: Int
    let content: String
    let sendTime: String
    var isActive: Bool
    let dayOfWeeks: [String]
}

enum DayOfWeek: String {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    
    var koreanValue: String {
        switch self {
        case .monday: "월요일"
        case .tuesday: "화요일"
        case .wednesday: "수요일"
        case .thursday: "목요일"
        case .friday: "금요일"
        case .saturday: "토요일"
        case .sunday: "일요일"
        }
    }
}
