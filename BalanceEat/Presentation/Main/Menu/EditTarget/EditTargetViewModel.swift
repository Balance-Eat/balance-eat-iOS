//
//  EditTargetViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/12/25.
//

import Foundation
import RxSwift
import RxCocoa

final class EditTargetViewModel {
    private let userUseCase: UserUseCaseProtocol
    
    let loadingRelay = BehaviorRelay<Bool>(value: false)
    let errorRelay = PublishRelay<String>()
    
    let userRelay = BehaviorRelay<User?>(value: nil)
    let updateUserResultRelay = PublishRelay<Bool>()
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    func updateUser(userDTO: UserDTO) async {
        let updateUserResponse = await userUseCase.updateUser(userDTO: userDTO)
        
        loadingRelay.accept(true)
        
        switch updateUserResponse {
        case .success(()):
            print("사용자 정보 수정 성공")
            updateUserResultRelay.accept(true)
        case .failure(let failure):
            print("사용자 정보 수정 실패: \(failure.localizedDescription)")
            updateUserResultRelay.accept(false)
            errorRelay.accept(failure.localizedDescription)
            loadingRelay.accept(false)
        }
    }
}
