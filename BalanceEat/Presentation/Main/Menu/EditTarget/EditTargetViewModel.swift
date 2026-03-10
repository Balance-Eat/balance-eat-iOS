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
    
    let updateUserResultRelay = PublishRelay<Bool>()
    
    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
    }
    
    func updateUser(userDTO: UserDTO) async {
        loadingRelay.accept(true)
        
        let updateUserResponse = await userUseCase.updateUser(userDTO: userDTO)
        
        switch updateUserResponse {
        case .success(()):
            #if DEBUG
            print("사용자 정보 수정 성공")
            #endif
            updateUserResultRelay.accept(true)
            loadingRelay.accept(false)
        case .failure(let failure):
            updateUserResultRelay.accept(false)
            toastMessageRelay.accept("사용자 정보 수정 실패: \(failure.description)")
            loadingRelay.accept(false)
        }
    }
}
