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
    
    let toastMessageRelay = BehaviorRelay<String?>(value: nil)
    let searchQueryRelay = BehaviorRelay<String>(value: "")
    let searchFoodResultRelay = BehaviorRelay<[FoodDTOForSearch]>(value: [])
    let isLoadingNextPageRelay: BehaviorRelay<Bool> = .init(value: false)
    let errorMessageRelay = PublishRelay<String>()
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    var isLastPage: Bool { currentPage == totalPage }
    let pageSize: Int = 20
    
    init(foodUseCase: FoodUseCaseProtocol) {
        self.foodUseCase = foodUseCase
    }
    
    func searchFood(foodName: String) async {
        
        currentPage = 0
  
        let searchFoodResponse = await foodUseCase.searchFood(foodName: foodName, page: currentPage, size: pageSize)
        
        switch searchFoodResponse {
        case .success(let searchResponseDTO):
            searchFoodResultRelay.accept(searchResponseDTO.items)
            totalPage = searchResponseDTO.totalPages
        case .failure(let failure):
            errorMessageRelay.accept(failure.localizedDescription)
        }
    }
    
    func fetchSearchFood(foodName: String) async {
        guard !isLastPage else { return }
        
        isLoadingNextPageRelay.accept(true)
        
        currentPage += 1
        
        let searchFoodResponse = await foodUseCase.searchFood(foodName: foodName, page: currentPage, size: pageSize)
        
        switch searchFoodResponse {
        case .success(let searchResponseDTO):
            searchFoodResultRelay.accept(searchFoodResultRelay.value + searchResponseDTO.items)
            isLoadingNextPageRelay.accept(false)
        case .failure(let error):
            toastMessageRelay.accept(error.description)
            isLoadingNextPageRelay.accept(false)
        }
    
    }
}
