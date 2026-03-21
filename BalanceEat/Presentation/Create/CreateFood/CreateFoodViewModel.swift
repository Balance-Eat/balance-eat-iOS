//
//  CreateFoodViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/20/25.
//

import Foundation
import RxSwift
import RxCocoa
import UUIDV7

final class CreateFoodViewModel: BaseViewModel {
    private let foodUseCase: FoodUseCaseProtocol

    let createFoodResultRelay = PublishRelay<FoodData>()

    let nameRelay = BehaviorRelay(value: "")
    let amountRelay = BehaviorRelay<Double>(value: 0)
    let unitRelay = BehaviorRelay(value: "")
    let carbonRelay = BehaviorRelay<Double>(value: 0)
    let proteinRelay = BehaviorRelay<Double>(value: 0)
    let fatRelay = BehaviorRelay<Double>(value: 0)
    let brandNameRelay = BehaviorRelay(value: "")

    var calculatedCalorieObservable: Observable<Double> {
        Observable.combineLatest(carbonRelay, proteinRelay, fatRelay)
            .map { carbon, protein, fat in carbon * 4 + protein * 4 + fat * 9 }
    }

    var isInvalidInputObservable: Observable<Bool> {
        Observable.combineLatest(nameRelay, amountRelay, unitRelay, carbonRelay, proteinRelay, fatRelay)
            .map { (name: String, amount: Double, unit: String, carbon: Double, protein: Double, fat: Double) -> Bool in
                name.isEmpty || amount == 0 || unit.isEmpty || carbon == 0 || protein == 0 || fat == 0
            }
    }

    var isResetHiddenObservable: Observable<Bool> {
        Observable.combineLatest(nameRelay, amountRelay, unitRelay, carbonRelay, proteinRelay, fatRelay, brandNameRelay)
            .map { (name: String, amount: Double, unit: String, carbon: Double, protein: Double, fat: Double, brandName: String) -> Bool in
                name.isEmpty && amount == 0 && unit.isEmpty && carbon == 0 && protein == 0 && fat == 0 && brandName.isEmpty
            }
    }

    init(foodUseCase: FoodUseCaseProtocol) {
        self.foodUseCase = foodUseCase
        super.init()
    }

    @MainActor
    func createFood() async {
        let request = FoodCreateRequest(
            uuid: UUID.uuidV7String(),
            name: nameRelay.value,
            servingSize: amountRelay.value,
            unit: unitRelay.value,
            carbohydrates: carbonRelay.value,
            protein: proteinRelay.value,
            fat: fatRelay.value,
            brand: brandNameRelay.value.isEmpty ? "없음" : brandNameRelay.value
        )

        loadingRelay.accept(true)
        let createFoodResponse = await foodUseCase.createFood(request: request)

        switch createFoodResponse {
        case .success(let foodData):
            createFoodResultRelay.accept(foodData)
            loadingRelay.accept(false)
        case .failure(let error):
            loadingRelay.accept(false)
            toastMessageRelay.accept("음식 생성에 실패했습니다: \(error.description)")
        }
    }
}
