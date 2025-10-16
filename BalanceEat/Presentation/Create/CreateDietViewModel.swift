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
    
    let dietFoodsRelay = BehaviorRelay<[String: [DietFoodData]]>(value: [:])
    let currentFoodsRelay = BehaviorRelay<[DietFoodData]>(value: [])
    let createDietSuccessRelay = PublishRelay<Void>()
    let mealTimeRelay = BehaviorRelay<MealType>(value: .breakfast)
    let dateRelay: BehaviorRelay<Date> = BehaviorRelay(value: Date())
    
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
            current[dietData.mealType.rawValue, default: []].append(contentsOf: dietData.items)
            dietFoodsRelay.accept(current)
        }
                
        let mealTimeKey = mealTimeRelay.value.rawValue
        let currentFoods = dietFoodsRelay.value[mealTimeKey] ?? []
        
        currentFoodsRelay.accept(currentFoods)
    }
    
    private func setBinding() {
        mealTimeRelay
            .subscribe(onNext: { [weak self] mealTime in
                guard let self else { return }
                
                let mealTimeKey = mealTime.rawValue
                let currentFoods = dietFoodsRelay.value[mealTimeKey] ?? []
                print("mealTimeRelay: \(mealTimeKey), dietFoodsRelay: \(dietFoodsRelay.value)")
                currentFoodsRelay.accept(currentFoods)
            })
            .disposed(by: disposeBag)
    }
    
    func createDiet(mealType: MealType, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async {
        loadingRelay.accept(true)
        
        let createDietResponse = await dietUseCase.createDiet(mealType: mealType, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
        
        switch createDietResponse {
        case .success(let createDietResponseDTO):
            createDietSuccessRelay.accept(())
            loadingRelay.accept(false)
        case .failure(let failure):
            errorMessageRelay.accept(failure.localizedDescription)
            loadingRelay.accept(false)
        }
    }
    
    func deleteFood(food: DietFoodData) {
        var current = dietFoodsRelay.value
        let key = mealTimeRelay.value.title
        if var items = current[key] {
            if let index = items.firstIndex(where: { $0.id == food.id }) {
                items.remove(at: index)
                current[key] = items
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
            errorMessageRelay.accept(failure.localizedDescription)
            return ""
        }
    }
}
