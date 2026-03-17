//
//  ReminderData+Fixture.swift
//  BalanceEatTests
//

@testable import BalanceEat

extension ReminderData {
    static func fixture(
        id: Int = 1,
        content: String = "단백질 섭취하기",
        sendTime: String = "08:00",
        isActive: Bool = true,
        dayOfWeeks: [String] = ["MONDAY"]
    ) -> ReminderData {
        ReminderData(
            id: id,
            content: content,
            sendTime: sendTime,
            isActive: isActive,
            dayOfWeeks: dayOfWeeks
        )
    }
}

extension ReminderListData {
    static func fixture(
        totalItems: Int = 1,
        currentPage: Int = 0,
        itemsPerPage: Int = 10,
        items: [ReminderData] = [.fixture()],
        totalPages: Int = 1
    ) -> ReminderListData {
        ReminderListData(
            totalItems: totalItems,
            currentPage: currentPage,
            itemsPerPage: itemsPerPage,
            items: items,
            totalPages: totalPages
        )
    }
}

extension ReminderDetailData {
    static func fixture(
        id: Int = 1,
        userId: Int = 1,
        content: String = "단백질 섭취하기",
        sendTime: String = "08:00",
        isActive: Bool = true,
        dayOfWeeks: [String] = ["MONDAY"],
        createdAt: String = "2026-03-01T00:00:00",
        updatedAt: String = "2026-03-01T00:00:00"
    ) -> ReminderDetailData {
        ReminderDetailData(
            id: id,
            userId: userId,
            content: content,
            sendTime: sendTime,
            isActive: isActive,
            dayOfWeeks: dayOfWeeks,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension NotificationData {
    static func fixture(
        id: Int = 1,
        userId: Int = 1,
        agentId: String = "test-agent-id",
        osType: String = "IOS",
        deviceName: String = "iPhone",
        isActive: Bool = true
    ) -> NotificationData {
        NotificationData(
            id: id,
            userId: userId,
            agentId: agentId,
            osType: osType,
            deviceName: deviceName,
            isActive: isActive
        )
    }
}
