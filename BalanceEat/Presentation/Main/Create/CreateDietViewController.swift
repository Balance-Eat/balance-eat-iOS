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
            searchInputField
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
        let view = MealTimePickerView(selectedMealTime: mealTime)
        view.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        return view
    }()
    
    private lazy var mealTimeTitledView = TitledContainerView(
        title: "언제 드셨나요?",
        contentView: mealTimePickerView
    )
    
    private lazy var addedFoodListView = AddedFoodListView(foodItemsRelay: viewModel.addedFoodsRelay)
    
    private let saveButton = TitledButton(
        title: "저장",
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.5)]
        )
    )
    
    let dateRelay: BehaviorRelay<Date> = BehaviorRelay(value: Date())
    private var mealTime: MealTime = .breakfast
    
    private let favoriteFoods: [FavoriteFood] = [
        FavoriteFood(iconImage: .chickenChest, name: "닭가슴살", calorie: 165),
        FavoriteFood(iconImage: .salad, name: "샐러드", calorie: 100),
        FavoriteFood(iconImage: .googleLogo, name: "구글", calorie: 999),
        FavoriteFood(iconImage: .kakaoLogo, name: "카카오", calorie: 1010)
    ]
    
    init() {
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        
        let dietRepository = DietRepository()
        let dietUseCase = DietUseCase(repository: dietRepository)
        
        let vm = CreateDietViewModel(dietUseCase: dietUseCase, userUseCase: userUseCase)
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
    
    private func setUpView() {
        topContentView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        [dateLabel, mealTimeTitledView, searchMealTitledView, addedFoodListView, saveButton].forEach(mainStackView.addArrangedSubview(_:))
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        mealTimeTitledView.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func setBinding() {
//        searchInputField.textObservable
//            .compactMap { $0 }
//            .distinctUntilChanged()
//            .bind { text in
//                print("📝 입력된 텍스트: \(text)")
//            }
//            .disposed(by: disposeBag)
//        
//        searchInputField.searchTap
//            .bind {
//                print("🔍 돋보기 아이콘 눌림!")
//            }
//            .disposed(by: disposeBag)
//
        dateRelay
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
            .bind { [weak self] in
                guard let self else { return }
                let searchFoodViewController = SearchFoodViewController()
                
                searchFoodViewController.selectedFoodDataRelay
                    .subscribe(onNext: { [weak self] foodData in
                        guard let self else { return }
                        guard let foodData else { return }
                        
                        viewModel.addedFoodsRelay.accept(self.viewModel.addedFoodsRelay.value + [foodData])
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
        
        viewModel.addedFoodsRelay
            .map { $0.count > 0 }
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
                    
                    
                    let mealTime = mealTimePickerView.selectedMealTime
                    let consumedAt = Date().toString(format: "yyyy-MM-dd'T'HH:mm:ss")
                    let dietFoods = viewModel.addedFoodsRelay.value.map { [weak self] food in
                        
                        if let servingSize = self?.addedFoodListView.cellServingSizeRelay.value[food.uuid] {
                            FoodItemForCreateDietDTO(
                                foodId: food.id,
                                intake: servingSize
                            )
                        } else {
                            FoodItemForCreateDietDTO(foodId: -1, intake: -1)
                        }
                    }
                    let userId = viewModel.getUserId()
                    Task {
                        await self.viewModel.createDiet(
                            mealTime: mealTime,
                            consumedAt: consumedAt,
                            dietFoods: dietFoods,
                            userId: userId
                        )
                }
            })
            .disposed(by: disposeBag)
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
