//
//  CreateFoodViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CreateFoodViewModel {
    private let foodUseCase: FoodUseCaseProtocol
    
    let createFoodResultRelay = PublishRelay<Bool>()
    
    init(foodUseCase: FoodUseCaseProtocol) {
        self.foodUseCase = foodUseCase
    }
    
    func createFood(createFoodDTO: CreateFoodDTO) async {
        let createFoodResponse = await foodUseCase.createFood(createFoodDTO: createFoodDTO)
        
        switch createFoodResponse {
        case .success(let foodData):
            createFoodResultRelay.accept(true)
            
        case .failure(let failure):
            createFoodResultRelay.accept(false)
        }
    }
}
