//
//  CreateDietViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CreateDietViewModel: BaseViewModel {
    private let dietUseCase: DietUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    var originalDietFoodDatas: [String: DietData] = [:]
    let dietFoodsRelay = BehaviorRelay<[String: DietData]>(value: [:])
    let currentFoodsRelay = BehaviorRelay<DietData?>(value: nil)
    let createDietSuccessRelay = PublishRelay<Void>()
    let mealTimeRelay = BehaviorRelay<MealType>(value: .breakfast)
    let dateRelay: BehaviorRelay<Date> = BehaviorRelay(value: Date())
    
    let dataChangedRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let deleteButtonIsEnabledRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    init(dietUseCase: DietUseCaseProtocol, userUseCase: UserUseCaseProtocol, dietDatas: [DietData], date: Date) {
        self.dietUseCase = dietUseCase
        self.userUseCase = userUseCase
        self.dateRelay.accept(date)
        super.init()
        setDietData(dietDatas: dietDatas)
        setBinding()
    }
    
    private func setDietData(dietDatas: [DietData]) {
        for dietData in dietDatas {
            var current = dietFoodsRelay.value
            current[dietData.mealType.rawValue] = dietData
            dietFoodsRelay.accept(current)
        }
        
        self.originalDietFoodDatas = dietFoodsRelay.value
                
        let mealTimeKey = mealTimeRelay.value.rawValue
        let currentFoods = dietFoodsRelay.value[mealTimeKey]
        
        currentFoodsRelay.accept(currentFoods)
        
        self.deleteButtonIsEnabledRelay.accept(currentFoods != nil)
    }
    
    private func setBinding() {
        dietFoodsRelay
            .subscribe(onNext: { [weak self] dietFoods in
                guard let self else { return }
                
                let mealTimeKey = mealTimeRelay.value.rawValue
                let currentFoods = dietFoods[mealTimeKey]
                                
                currentFoodsRelay.accept(currentFoods)
            })
            .disposed(by: disposeBag)
        
        mealTimeRelay
            .subscribe(onNext: { [weak self] mealTime in
                guard let self else { return }
                
                let mealTimeKey = mealTime.rawValue
                let currentFoods = dietFoodsRelay.value[mealTimeKey]
                
                currentFoodsRelay.accept(currentFoods)
                
                var deleteButtonIsEnabled: Bool
                if currentFoods == nil {
                    deleteButtonIsEnabled = false
                } else if currentFoods?.id == -1 {
                    deleteButtonIsEnabled = false
                } else {
                    deleteButtonIsEnabled = true
                }
                    
                self.deleteButtonIsEnabledRelay.accept(deleteButtonIsEnabled)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(currentFoodsRelay, mealTimeRelay)
            .subscribe(onNext: { [weak self] currentFoods, mealTime in
                guard let self else { return }
                
                let mealTimeKey = mealTime.rawValue
                if originalDietFoodDatas[mealTimeKey]?.items == currentFoods?.items {
                    dataChangedRelay.accept(false)
                } else {
                    dataChangedRelay.accept(true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async {
        loadingRelay.accept(true)
        
        let createDietResponse = await dietUseCase.createDiet(mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
        
        switch createDietResponse {
        case .success(_):
            createDietSuccessRelay.accept(())
            loadingRelay.accept(false)
            toastMessageRelay.accept("식단 저장을 완료했습니다.")
        case .failure(let failure):
            toastMessageRelay.accept(failure.localizedDescription)
            loadingRelay.accept(false)
        }
    }
    
    func updateDiet(dietId: Int, mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async {
        loadingRelay.accept(true)
        
        let updateDietResponse = await dietUseCase.updateDiet(dietId: dietId, mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
        
        switch updateDietResponse {
        case .success(_):
            loadingRelay.accept(false)
            
            toastMessageRelay.accept("식단 수정을 완료했습니다.")
        case .failure(let failure):
            toastMessageRelay.accept(failure.localizedDescription)
            loadingRelay.accept(false)
        }
    }
    
    func deleteDiet(dietId: Int, userId: String) async {
        loadingRelay.accept(true)
        
        let deleteDietResponse = await dietUseCase.deleteDiet(dietId: dietId, userId: userId)
        
        switch deleteDietResponse {
        case .success(_):
            loadingRelay.accept(false)
            resetCurrentDiet()
            toastMessageRelay.accept("식단 삭제를 완료했습니다.")
        case .failure(let failure):
            toastMessageRelay.accept(failure.localizedDescription)
            loadingRelay.accept(false)
        }
    }
    
    func deleteFood(food: DietFoodData) {
        var current = dietFoodsRelay.value
        let key = mealTimeRelay.value.rawValue
        
        if var items = current[key]?.items {
            if let index = items.firstIndex(where: { $0.id == food.id }) {
                items.remove(at: index)
                current[key]?.items = items
                dietFoodsRelay.accept(current)
            }
        }
    }
    
    func getUserId() -> String {
        let userIdResponse = userUseCase.getUserId()
        
        switch userIdResponse {
        case .success(let userId):
            return String(userId)
        case .failure(let failure):
            toastMessageRelay.accept(failure.localizedDescription)
            return ""
        }
    }
    
    private func resetCurrentDiet() {
        let mealTypeString = mealTimeRelay.value.rawValue
        
        var current = dietFoodsRelay.value
        current[mealTypeString] = nil
        dietFoodsRelay.accept(current)
        
        currentFoodsRelay.accept(nil)
        deleteButtonIsEnabledRelay.accept(false)
    }
}
