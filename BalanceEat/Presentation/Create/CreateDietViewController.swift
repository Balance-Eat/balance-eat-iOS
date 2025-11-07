//
//  CreateViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CreateDietViewController: BaseViewController<CreateDietViewModel> {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private let searchInputField = SearchInputField(placeholder: "음식 이름을 입력하세요")
    private lazy var favoriteFoodGridView = FavoriteFoodGridView(favoriteFoods: favoriteFoods)
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            searchInputField,
//            favoriteFoodGridView
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var searchMealTitledView = TitledContainerView(
        title: "음식 검색",
        contentView: searchStackView
    )
    
    private lazy var mealTimePickerView: MealTimePickerView = {
        let view = MealTimePickerView(selectedMealTimeRelay: viewModel.mealTimeRelay)
        view.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        return view
    }()
    
    private lazy var mealTimeTitledView = TitledContainerView(
        title: "언제 드셨나요?",
        contentView: mealTimePickerView
    )
    
    private let addedFoodListView = AddedFoodListView()
    
    private let saveButton = TitledButton(
        title: "저장",
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.5)]
        )
    )
    private let deleteButton = TitledButton(
        title: "삭제",
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.red, .red.withAlphaComponent(0.5)]
        )
    )
    
    private let favoriteFoods: [FavoriteFood] = [
        FavoriteFood(iconImage: .chickenChest, name: "닭가슴살", calorie: 165),
        FavoriteFood(iconImage: .salad, name: "샐러드", calorie: 100),
        FavoriteFood(iconImage: .googleLogo, name: "구글", calorie: 999),
        FavoriteFood(iconImage: .kakaoLogo, name: "카카오", calorie: 1010)
    ]
    
    init(dietDatas: [DietData], date: Date) {
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        
        let dietRepository = DietRepository()
        let dietUseCase = DietUseCase(repository: dietRepository)
                
        let vm = CreateDietViewModel(dietUseCase: dietUseCase, userUseCase: userUseCase, dietDatas: dietDatas, date: date)
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    
    private func setUpView() {
        topContentView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        [dateLabel, mealTimeTitledView, searchMealTitledView, addedFoodListView, saveButton, deleteButton].forEach(mainStackView.addArrangedSubview(_:))
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        mealTimeTitledView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        navigationItem.title = "식단"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setBinding() {
        
        viewModel.currentFoodsRelay
            .map { $0?.items ?? [] }
            .bind(to: addedFoodListView.foodItemsRelay)
            .disposed(by: disposeBag)
        
        viewModel.dateRelay
            .map { [weak self] date in
                guard let self else { return "" }
                
                if isToday(date) {
                    return "오늘의 식단"
                } else {
                    return formattedMealDate(date)
                }
            }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        searchInputField.textField.rx.controlEvent(.editingDidBegin)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                guard let self else { return }
                let searchFoodViewController = SearchFoodViewController()
                
                searchFoodViewController.selectedFoodDataRelay
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onNext: { [weak self] foodData in
                            guard let self else { return }
                            guard let foodData else { return }
                            
                            let mealTime = viewModel.mealTimeRelay.value
                            var current = viewModel.dietFoodsRelay.value
                            current[
                                mealTime.rawValue,
                                default: DietData(
                                    id: -1,
                                    consumeDate: "",
                                    consumedAt: "",
                                    mealType: mealTime,
                                    items: []
                                )
                            ].items.append(foodData.modelToDietFoodData(intake: foodData.servingSize))
                                                
                        viewModel.dietFoodsRelay.accept(current)
                        viewModel.mealTimeRelay.accept(mealTime)
                    })
                    .disposed(by: disposeBag)
                
                self.navigationController?.pushViewController(searchFoodViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        favoriteFoodGridView.tappedIndexObservable
            .subscribe(
                onNext: { [weak self] index in
                    guard let self = self,
                          index < self.favoriteFoods.count else { return }
                    print("선택된 food index: \(index)")
                    let favoriteFood = self.favoriteFoods[index]
                    let addFoodViewController = AddFoodViewController(
                        foodItem: FooddddItem(
                            id: UUID(),
                            name: favoriteFood.name,
                            amount: 200,
                            unit: "gram",
                            nutritionalInfo: NutritionalInfo(calories: Double(favoriteFood.calorie), carbs: 100, protein: 30, fat: 20)
                        )
                    )
                    
                    addFoodViewController.modalPresentationStyle = .overCurrentContext
                    addFoodViewController.modalTransitionStyle = .crossDissolve
                    
                    present(addFoodViewController, animated: true, completion: nil)
                })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.currentFoodsRelay, viewModel.dataChangedRelay)
            .subscribe(onNext: { [weak self] foods, dataChanged in
                guard let self else { return }
                
                if dataChanged && foods?.items.count ?? 0 > 0 {
                    saveButton.isEnabled = true
                } else {
                    saveButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.currentFoodsRelay
            .map { $0?.items.count ?? 0 > 0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        addedFoodListView.deletedFoodItem
            .subscribe(onNext: { [weak self] item in
                guard let self = self else { return }
                
                viewModel.deleteFood(food: item)
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    guard let self else { return }
                    
                    let mealType = viewModel.mealTimeRelay.value
                    let consumedAt = viewModel.dateRelay.value.toString(format: "yyyy-MM-dd'T'HH:mm:ss")
//                    let todayConsumedAt = Date().toString(format: "yyyy-MM-dd'T'HH:mm:ss")
                    let mealTypeString = mealType.rawValue
                    if let diet = viewModel.dietFoodsRelay.value[mealTypeString] {
                        let dietFoods = diet.items.map { [weak self] food in
                            if let servingSize = self?.addedFoodListView.cellServingSizeRelay.value[String(food.id)] {
                                return FoodItemForCreateDietDTO(
                                    foodId: food.id,
                                    intake: servingSize
                                )
                            } else {
                                return FoodItemForCreateDietDTO(
                                    foodId: -1,
                                    intake: -1
                                )
                            }
                        }
                        
                        let userId = viewModel.getUserId()
                        
                        if viewModel.currentFoodsRelay.value?.id == -1 {
                            Task {
                                await self.viewModel.createDiet(
                                    mealType: mealType,
                                    consumedAt: consumedAt,
                                    dietFoods: dietFoods,
                                    userId: userId
                                )
                            }
                        } else {
                            let consumedAt = diet.consumedAt
                            Task {
                                await self.viewModel.updateDiet(
                                    dietId: diet.id,
                                    mealType: mealType,
                                    consumedAt: consumedAt,
                                    dietFoods: dietFoods,
                                    userId: userId
                                )
                            }
                        }
                    }
            })
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let mealTypeString = viewModel.mealTimeRelay.value.rawValue
                let userId = viewModel.getUserId()
                if let diet = viewModel.dietFoodsRelay.value[mealTypeString] {
                    let alert = UIAlertController(
                        title: "식단 삭제",
                        message: "식단을 삭제하시겠습니까?",
                        preferredStyle: .alert
                    )
                    
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                        Task {
                            await self.viewModel.deleteDiet(dietId: diet.id, userId: userId)
                        }
                    }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(deleteAction)
                    
                    self.present(alert, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.deleteButtonIsEnabledRelay
            .bind(to: deleteButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func formattedMealDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 '식단'"
        return formatter.string(from: date)
    }
}
