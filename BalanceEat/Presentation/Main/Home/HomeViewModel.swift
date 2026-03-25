//
//  HomeViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/21/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let dietUseCase: DietUseCaseProtocol
    
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()
    
    let userResponseRelay = BehaviorRelay<UserData?>(value: nil)
    let dietResponseRelay = BehaviorRelay<[DietData]?>(value: nil)

    let userNameRelay: BehaviorRelay<String> = .init(value: "")
    /// (weight, smi, fatPercentage)
    let userNowBodyStatusRelay: BehaviorRelay<(Double, Double?, Double?)> = .init(value: (0, nil, nil))
    let userTargetBodyStatusRelay: BehaviorRelay<(Double, Double?, Double?)> = .init(value: (0, nil, nil))

    let dailyNutritionSummaryRelay: BehaviorRelay<NutritionAchievement> = .init(value: NutritionAchievement(calorieRate: 0, carbohydrateRate: 0, proteinRate: 0, fatRate: 0))
    let bodyStatusDiffRelay: BehaviorRelay<(weightDiff: Double, smiDiff: Double?, fatDiff: Double?)> = .init(value: (0, nil, nil))
    
    init(userUseCase: UserUseCaseProtocol, dietUseCase: DietUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.dietUseCase = dietUseCase
        
        super.init()
        setBinding()
    }
    
    private func setBinding() {
        userResponseRelay
            .subscribe(onNext: { [weak self] user in
                guard let self else { return }

                userNameRelay.accept(user?.name ?? "")

                userNowBodyStatusRelay.accept((user?.weight ?? 0, user?.smi, user?.fatPercentage))
                userTargetBodyStatusRelay.accept((user?.targetWeight ?? 0, user?.targetSmi, user?.targetFatPercentage))
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(dietResponseRelay.compactMap { $0 }, userResponseRelay.compactMap { $0 })
            .subscribe(onNext: { [weak self] dietList, user in
                guard let self else { return }
                let achievement = dietUseCase.calculateNutritionAchievement(diets: dietList, target: user)
                dailyNutritionSummaryRelay.accept(achievement)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(userNowBodyStatusRelay, userTargetBodyStatusRelay)
            .subscribe(onNext: { [weak self] bodyStatus, targetBodyStatus in
                guard let self else { return }
                let weightDiff = targetBodyStatus.0 - bodyStatus.0
                let smiDiff: Double? = {
                    if let target = targetBodyStatus.1, let current = bodyStatus.1 { return target - current }
                    return nil
                }()
                let fatDiff: Double? = {
                    if let target = targetBodyStatus.2, let current = bodyStatus.2 { return target - current }
                    return nil
                }()
                bodyStatusDiffRelay.accept((weightDiff: weightDiff, smiDiff: smiDiff, fatDiff: fatDiff))
            })
            .disposed(by: disposeBag)
    }
    
    @MainActor
    func getUser() async {
        guard let uuid = getUserUUID() else { return }

        loadingRelay.accept(true)
        let getUserResponse = await userUseCase.getUser(uuid: uuid)
        
        switch getUserResponse {
        case .success(let user):
            userResponseRelay.accept(user)
            saveUserId(user.id)
            loadingRelay.accept(false)
        case .failure(let failure):
            toastMessageRelay.accept("사용자 정보 불러오기 실패: \(failure.description)")
            loadingRelay.accept(false)
        }
    }
    
    private func getUserUUID() -> String? {
        switch userUseCase.getUserUUID() {
        case .success(let uuid):
            return uuid
        case .failure(let failure):
            toastMessageRelay.accept("UUID 불러오기 실패: \(failure.description)")
            return nil
        }
    }
    
    private func saveUserId(_ userId: Int) {
        if case .failure(let error) = userUseCase.saveUserId(Int64(userId)) {
            toastMessageRelay.accept("userId 저장 실패: \(error.description)")
        }
    }
    
    @MainActor
    func getDailyDiet() async {
        guard let userId = userResponseRelay.value?.id else {
            return
        }
        
        loadingRelay.accept(true)
        let getDailyDietResponse = await dietUseCase.getDailyDiet(date: Date(), userId: String(userId))
        
        switch getDailyDietResponse {
        case .success(let dietDataList):
            #if DEBUG
            print("일일 식단 정보: \(dietDataList)")
            #endif
            dietResponseRelay.accept(dietDataList)
            loadingRelay.accept(false)
        case .failure(let failure):
            toastMessageRelay.accept("일일 식단 정보 불러오기 실패: \(failure.description)")
            loadingRelay.accept(false)
        }
    }
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func formatConsumedTime(_ dateString: String) -> String {
        guard let date = HomeViewModel.isoFormatter.date(from: dateString) else { return "" }
        return HomeViewModel.timeFormatter.string(from: date)
    }
}
