//
//  SearchFoodVIewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/22/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchFoodViewModel {
    private let foodUseCase: FoodUseCaseProtocol
    
    let searchFoodResultRelay = BehaviorRelay<[FoodDTOForSearch]>(value: [])
    let errorMessageRelay = PublishRelay<String>()
    var page: Int = 0
    var size: Int = 10
    
    init(foodUseCase: FoodUseCaseProtocol) {
        self.foodUseCase = foodUseCase
    }
    
    func searchFood(foodName: String, isNew: Bool) async {
        
        if isNew {
            page = 0
            size = 10
        } else {
            page += 1
        }
        
        let searchFoodResponse = await foodUseCase.searchFood(foodName: foodName, page: page, size: size)
        
        switch searchFoodResponse {
        case .success(let searchResponseDTO):
            searchFoodResultRelay.accept(searchResponseDTO.items)
        case .failure(let failure):
            errorMessageRelay.accept(failure.localizedDescription)
        }
    }
}
