//
//  SetRemindNotiViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 11/30/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SetRemindNotiViewModel: BaseViewModel {
    private let notificationUseCase: NotificationUseCaseProtocol
    
    init(notificationUseCase: NotificationUseCaseProtocol) {
        self.notificationUseCase = notificationUseCase
        super.init()
    }
}
