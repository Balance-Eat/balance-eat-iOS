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

final class CreateViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let searchInputField = SearchInputField(placeholder: "음식 이름을 입력하세요")
    private lazy var favoriteFoodGridView = FavoriteFoodGridView(favoriteFoods: favoriteFoods)
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            searchInputField,
            favoriteFoodGridView
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
    
    private let addedFoodListView = AddedFoodListView()
    
    private let saveButton = TitledButton(
        title: "저장",
        style: .init(
            backgroundColor: .systemBlue,
            titleColor: .white,
            borderColor: nil
        )
    )
    
    private let disposeBag = DisposeBag()
    private var mealTime: MealTime = .breakfast
    
    private let favoriteFoods: [FavoriteFood] = [
        FavoriteFood(iconImage: .chickenChest, name: "닭가슴살", calorie: 165),
        FavoriteFood(iconImage: .salad, name: "샐러드", calorie: 100),
        FavoriteFood(iconImage: .googleLogo, name: "구글", calorie: 999),
        FavoriteFood(iconImage: .kakaoLogo, name: "카카오", calorie: 1010)
    ]
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUpView() {
        view.backgroundColor = .homeScreenBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mealTimeTitledView)
        contentView.addSubview(searchMealTitledView)
        contentView.addSubview(addedFoodListView)
        contentView.addSubview(saveButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        mealTimeTitledView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        searchMealTitledView.snp.makeConstraints { make in
            make.top.equalTo(mealTimeTitledView.snp.bottom).offset(20)
            make.leading.trailing.equalTo(mealTimeTitledView)
//            make.bottom.equalToSuperview().inset(20)
        }
        
        addedFoodListView.snp.makeConstraints { make in
            make.top.equalTo(searchMealTitledView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(addedFoodListView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func setBinding() {
        searchInputField.textObservable
            .compactMap { $0 }
            .distinctUntilChanged()
            .bind { text in
                print("📝 입력된 텍스트: \(text)")
            }
            .disposed(by: disposeBag)
        
        searchInputField.searchTap
            .bind {
                print("🔍 돋보기 아이콘 눌림!")
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
                        foodItem: FoodItem(
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
    }
}
