//
//  SearchFoodViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/22/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchFoodViewModel: BaseViewModel {
    private let foodUseCase: FoodUseCaseProtocol

    let searchQueryRelay = BehaviorRelay<String>(value: "")
    let searchFoodResultRelay = BehaviorRelay<[FoodData]>(value: [])
    let isLoadingNextPageRelay: BehaviorRelay<Bool> = .init(value: false)
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    var isLastPage: Bool { currentPage == totalPage }
    let pageSize: Int = 20
    
    init(foodUseCase: FoodUseCaseProtocol) {
        self.foodUseCase = foodUseCase
        super.init()
    }
    
    @MainActor
    func searchFood(foodName: String) async {

        currentPage = 0

        let searchFoodResponse = await foodUseCase.searchFood(foodName: foodName, page: currentPage, size: pageSize)

        switch searchFoodResponse {
        case .success(let result):
            searchFoodResultRelay.accept(result.items)
            totalPage = result.totalPages
        case .failure(let failure):
            #if DEBUG
            print("SearchFoodViewModel.searchFood failed: \(failure)")
            #endif
            toastMessageRelay.accept(failure.description)
        }
    }
    
    @MainActor
    func fetchSearchFood(foodName: String) async {
        guard !isLastPage else { return }

        isLoadingNextPageRelay.accept(true)

        let searchFoodResponse = await foodUseCase.searchFood(foodName: foodName, page: currentPage + 1, size: pageSize)

        switch searchFoodResponse {
        case .success(let searchResponseDTO):
            searchFoodResultRelay.accept(searchFoodResultRelay.value + searchResponseDTO.items)
            currentPage += 1
            isLoadingNextPageRelay.accept(false)
        case .failure(let error):
            #if DEBUG
            print("SearchFoodViewModel.fetchSearchFood failed: \(error)")
            #endif
            toastMessageRelay.accept(error.description)
            isLoadingNextPageRelay.accept(false)
        }
    
    }
}
