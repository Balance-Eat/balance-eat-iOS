//
//  TutorialContentViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TutorialContentViewModel {
    private let userUseCase: UserUseCase
    
    let onCreateUserSuccessRelay: PublishRelay<Void> = .init()
    let onCreateUserFailureRelay: PublishRelay<String> = .init()
    
    init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }
    
    func createUser(createUserDTO: UserDTO) async {
        let createUserResponse = await userUseCase.createUser(userDTO: createUserDTO)
        
        switch createUserResponse {
        case .success():
            saveUserUUID(createUserDTO.uuid)
            onCreateUserSuccessRelay.accept(())
            
        case .failure(let failure):
            onCreateUserFailureRelay.accept(failure.localizedDescription)
        }
    }
    
    private func saveUserUUID(_ userUUID: String) {
        if case .failure(let error) = userUseCase.saveUserUUID(userUUID) {
            print("UUID 저장 실패: \(error.localizedDescription)")
        }
    }
    
    private func saveUserId(_ userId: Int) {
        if case .failure(let error) = userUseCase.saveUserId(Int64(userId)) {
            print("userId 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func getUserUUID() -> String {
        let getUserUUIDResponse = userUseCase.getUserUUID()
        
        switch getUserUUIDResponse {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            print("UUID 불러오기 실패: \(failure.localizedDescription)")
            return ""
        }
        
    }
}
