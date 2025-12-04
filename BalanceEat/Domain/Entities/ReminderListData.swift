//
//  ReminderListData.swift
//  BalanceEat
//
//  Created by 김견 on 12/4/25.
//

import Foundation

struct ReminderListData {
    let totalItems: Int
    var currentPage: Int
    let itemsPerPage: Int
    let items: [ReminderData]
    let totalPages: Int
}
