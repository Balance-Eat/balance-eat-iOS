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
    let userData: UserData

    let updateUserResultRelay = PublishRelay<Bool>()

    let currentWeightRelay: BehaviorRelay<Double?>
    let targetWeightRelay: BehaviorRelay<Double?>
    let currentSMIRelay: BehaviorRelay<Double?>
    let targetSMIRelay: BehaviorRelay<Double?>
    let currentFatPercentageRelay: BehaviorRelay<Double?>
    let targetFatPercentageRelay: BehaviorRelay<Double?>

    var isUnchangedObservable: Observable<Bool> {
        let originalUserData = userData
        return Observable.combineLatest(
            currentWeightRelay, targetWeightRelay,
            currentSMIRelay, targetSMIRelay,
            currentFatPercentageRelay, targetFatPercentageRelay
        ) { currentWeight, targetWeight, currentSMI, targetSMI, currentFatPercentage, targetFatPercentage -> Bool in
            currentWeight == originalUserData.weight
                && targetWeight == originalUserData.targetWeight
                && currentSMI == originalUserData.smi
                && targetSMI == originalUserData.targetSmi
                && currentFatPercentage == originalUserData.fatPercentage
                && targetFatPercentage == originalUserData.targetFatPercentage
        }
    }

    init(userData: UserData, userUseCase: UserUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.userData = userData
        self.currentWeightRelay = BehaviorRelay(value: userData.weight)
        self.targetWeightRelay = BehaviorRelay(value: userData.targetWeight)
        self.currentSMIRelay = BehaviorRelay(value: userData.smi)
        self.targetSMIRelay = BehaviorRelay(value: userData.targetSmi)
        self.currentFatPercentageRelay = BehaviorRelay(value: userData.fatPercentage)
        self.targetFatPercentageRelay = BehaviorRelay(value: userData.targetFatPercentage)
        super.init()
    }

    @MainActor
    func updateUser() async {
        let updatedUserData = UserData(
            id: userData.id,
            uuid: userData.uuid,
            name: userData.name,
            email: userData.email,
            gender: userData.gender,
            age: userData.age,
            weight: currentWeightRelay.value ?? 0,
            height: userData.height,
            goalType: userData.goalType,
            activityLevel: userData.activityLevel,
            smi: currentSMIRelay.value,
            fatPercentage: currentFatPercentageRelay.value,
            targetWeight: targetWeightRelay.value ?? 0,
            targetCalorie: userData.targetCalorie,
            targetSmi: targetSMIRelay.value,
            targetFatPercentage: targetFatPercentageRelay.value,
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
