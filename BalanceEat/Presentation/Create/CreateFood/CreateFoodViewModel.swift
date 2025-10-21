//
//  CreateFoodViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CreateFoodViewModel: BaseViewModel {
    private let foodUseCase: FoodUseCaseProtocol
    
    let createFoodResultRelay = PublishRelay<FoodData>()
    
    init(foodUseCase: FoodUseCaseProtocol) {
        self.foodUseCase = foodUseCase
    }
    
    func createFood(createFoodDTO: CreateFoodDTO) async {
        loadingRelay.accept(true)
        
        let createFoodResponse = await foodUseCase.createFood(createFoodDTO: createFoodDTO)
        
        switch createFoodResponse {
        case .success(let foodData):
            createFoodResultRelay.accept(foodData)
            loadingRelay.accept(false)
        case .failure(let failure):
            print("fail to create food: \(failure)")
            loadingRelay.accept(false)
            toastMessageRelay.accept("음식 생성에 실패했습니다.")
        }
    }
}
