//
//  EditTargetTypeAndActivityLevelViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 10/27/25.
//

import Foundation
import RxSwift
import RxCocoa

final class EditTargetTypeAndActivityLevelViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    
    let userRelay = BehaviorRelay<UserData?>(value: nil)
    let selectedGoalRelay: BehaviorRelay<GoalType> = .init(value: .none)
    let selectedActivityLevel: BehaviorRelay<ActivityLevel> = .init(value: .none)
    var BMRObservable: Observable<Int> {
        userRelay
            .map { data -> Int in
                let weight = Double(data?.weight ?? 0)
                let height = Double(data?.height ?? 0)
                let age = Double(data?.age ?? 0)
                
                switch data?.gender {
                case .male:
                    let result = 10 * weight + 6.25 * height - 5 * age + 5
                    return Int(result)
                case .female:
                    let result = 10 * weight + 6.25 * height - 5 * age - 161
                    return Int(result)
                default:
                    return 0
                }
            }
    }
    
    var targetCaloriesObservable: Observable<Int> {
        Observable.combineLatest(BMRObservable, selectedGoalRelay, selectedActivityLevel) { bmr, goal, activityLevel -> Int in
            let activityCoef = activityLevel.coefficient
            var goalDiff = 0
            
            if activityLevel != ActivityLevel.none {
                switch goal {
                case .diet:
                    goalDiff = -500
                case .bulkUp:
                    goalDiff = 300
                case .maintain:
                    goalDiff = 0
                case .none:
                    break
                }
            }
            return Int(Double(bmr) * activityCoef) + goalDiff
        }
    }
    
    let updateUserResultRelay = PublishRelay<Bool>()
    
    init(userData: UserData, userUseCase: UserUseCaseProtocol) {
        self.userRelay.accept(userData)
        self.userUseCase = userUseCase
    }
}
