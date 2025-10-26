//
//  EditBasicInfoViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 10/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class EditBasicInfoViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    
    let userRelay = BehaviorRelay<UserData?>(value: nil)
    let updateUserResultRelay = PublishRelay<Bool>()
    
    init(userData: UserData, userUseCase: UserUseCaseProtocol) {
        self.userRelay.accept(userData)
        self.userUseCase = userUseCase
    }
    
    func updateUser(userDTO: UserDTO) async {
        loadingRelay.accept(true)
        
        let updateUserResponse = await userUseCase.updateUser(userDTO: userDTO)
        
        switch updateUserResponse {
        case .success(()):
            print("사용자 정보 수정 성공")
            updateUserResultRelay.accept(true)
            loadingRelay.accept(false)
        case .failure(let failure):
            updateUserResultRelay.accept(false)
            toastMessageRelay.accept("사용자 정보 수정 실패: \(failure.localizedDescription)")
            loadingRelay.accept(false)
        }
    }
}
