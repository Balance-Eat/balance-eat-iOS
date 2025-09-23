//
//  CreateDietViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CreateDietViewModel {
    private let dietUseCase: DietUseCaseProtocol
    private let userUseCase: UserUseCaseProtocol
    
    let addedFoodsRelay = BehaviorRelay<[FoodData]>(value: [])
    let createDietSuccessRelay = PublishRelay<Void>()
    let errorMessageRelay = PublishRelay<String>()
    
    init(dietUseCase: DietUseCaseProtocol, userUseCase: UserUseCaseProtocol) {
        self.dietUseCase = dietUseCase
        self.userUseCase = userUseCase
    }
    
    func createDiet(mealTime: MealTime, consumedAt: String, dietFoods: [FoodItemForCreateDietDTO], userId: String) async {
        let createDietResponse = await dietUseCase.createDiet(mealTime: mealTime, consumedAt: consumedAt, dietFoods: dietFoods, userId: userId)
        
        switch createDietResponse {
        case .success(let createDietResponseDTO):
            createDietSuccessRelay.accept(())
        case .failure(let failure):
            errorMessageRelay.accept(failure.localizedDescription)
        }
    }
    
    func deleteFood(food: FoodData) {
        var current = addedFoodsRelay.value
        
        if let index = current.firstIndex(where: { $0.id == food.id }) {
            current.remove(at: index)
            addedFoodsRelay.accept(current)
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
