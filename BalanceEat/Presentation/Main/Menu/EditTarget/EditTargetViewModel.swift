//
//  EditTargetViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/12/25.
//

import Foundation
import RxSwift
import RxCocoa

final class EditTargetViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    
    let userRelay = BehaviorRelay<User?>(value: nil)
    let updateUserResultRelay = PublishRelay<Bool>()
    
    init(userUseCase: UserUseCaseProtocol) {
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
            errorMessageRelay.accept("사용자 정보 수정 실패: \(failure.localizedDescription)")
            loadingRelay.accept(false)
        }
    }
}
