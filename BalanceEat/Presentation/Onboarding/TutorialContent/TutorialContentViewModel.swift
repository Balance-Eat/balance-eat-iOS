//
//  TutorialContentViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TutorialContentViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol

    let onCreateUserSuccessRelay: PublishRelay<Void> = .init()

    init(userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
        super.init()
    }

    @MainActor
    func createUser(createUserDTO: UserDTO) async {
        loadingRelay.accept(true)

        let createUserResponse = await userUseCase.createUser(userDTO: createUserDTO)

        switch createUserResponse {
        case .success():
            saveUserUUID(createUserDTO.uuid)
            onCreateUserSuccessRelay.accept(())
            loadingRelay.accept(false)
        case .failure(let failure):
            loadingRelay.accept(false)
            toastMessageRelay.accept("유저 생성에 실패했습니다. \(failure.description)")
        }
    }

    private func saveUserUUID(_ userUUID: String) {
        if case .failure(let error) = userUseCase.saveUserUUID(userUUID) {
            toastMessageRelay.accept("UUID 저장 실패: \(error.description)")
        }
    }

    func getUserUUID() -> String? {
        switch userUseCase.getUserUUID() {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            toastMessageRelay.accept("UUID 불러오기 실패: \(failure.description)")
            return nil
        }
    }
}
