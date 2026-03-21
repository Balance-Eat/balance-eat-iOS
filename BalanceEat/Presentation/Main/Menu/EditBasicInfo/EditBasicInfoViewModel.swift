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

    let nameRelay: BehaviorRelay<String>
    let genderRelay: BehaviorRelay<Gender>
    let ageRelay: BehaviorRelay<Int>
    let heightRelay: BehaviorRelay<Double>

    var isUnchangedObservable: Observable<Bool> {
        Observable.combineLatest(nameRelay, genderRelay, ageRelay, heightRelay, userRelay) { name, gender, age, height, userData in
            name == userData?.name
                && gender == userData?.gender
                && age == userData?.age
                && height == userData?.height
        }
    }

    init(userData: UserData, userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.nameRelay = BehaviorRelay(value: userData.name)
        self.genderRelay = BehaviorRelay(value: userData.gender)
        self.ageRelay = BehaviorRelay(value: userData.age)
        self.heightRelay = BehaviorRelay(value: userData.height)
        super.init()
        self.userRelay.accept(userData)
    }

    @MainActor
    func updateUser() async {
        guard let userData = userRelay.value else { return }

        let updatedUserData = UserData(
            id: userData.id,
            uuid: userData.uuid,
            name: nameRelay.value,
            email: userData.email,
            gender: genderRelay.value,
            age: ageRelay.value,
            weight: userData.weight,
            height: heightRelay.value,
            goalType: userData.goalType,
            activityLevel: userData.activityLevel,
            smi: userData.smi,
            fatPercentage: userData.fatPercentage,
            targetWeight: userData.targetWeight,
            targetCalorie: userData.targetCalorie,
            targetSmi: userData.targetSmi,
            targetFatPercentage: userData.targetFatPercentage,
            targetCarbohydrates: userData.targetCarbohydrates,
            targetProtein: userData.targetProtein,
            targetFat: userData.targetFat,
            providerId: userData.providerId,
            providerType: userData.providerType
        )

        loadingRelay.accept(true)
        let updateUserResponse = await userUseCase.updateUser(userData: updatedUserData)

        switch updateUserResponse {
        case .success(()):
            updateUserResultRelay.accept(true)
            loadingRelay.accept(false)
        case .failure(let failure):
            updateUserResultRelay.accept(false)
            toastMessageRelay.accept("사용자 정보 수정 실패: \(failure.description)")
            loadingRelay.accept(false)
        }
    }
}
