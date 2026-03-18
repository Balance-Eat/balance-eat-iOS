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
    
    var makeSearchFoodViewController: (() -> SearchFoodViewController?)?
    private var searchPresentationBag = DisposeBag()

    override init(viewModel: CreateDietViewModel) {
        super.init(viewModel: viewModel)
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
                guard let searchFoodViewController = makeSearchFoodViewController?() else { return }

                searchPresentationBag = DisposeBag()

                searchFoodViewController.selectedFoodDataRelay
                    .observe(on: MainScheduler.instance)
                    .compactMap { $0 }
                    .take(1)
                    .subscribe(
                        onNext: { [weak self] foodData in
                            guard let self else { return }

                            let mealTime = viewModel.mealTimeRelay.value
                            var current = viewModel.dietFoodsRelay.value

                            if current[mealTime.rawValue]?.items.contains(where: { $0.id == foodData.id }) == true {
                                viewModel.toastMessageRelay.accept("이미 선택된 음식입니다.")
                                return
                            }
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
                    .disposed(by: searchPresentationBag)

                self.navigationController?.pushViewController(searchFoodViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.currentFoodsRelay, viewModel.dataChangedRelay)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] foods, dataChanged in
                guard let self else { return }
                
                if dataChanged && foods?.items.count ?? 0 > 0 {
                    saveButton.isEnabled = true
                } else {
                    saveButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        addedFoodListView.deletedFoodItem
            .subscribe(onNext: { [weak self] item in
                guard let self else { return }
                
                viewModel.deleteFood(food: item)
            })
            .disposed(by: disposeBag)
        
        addedFoodListView.cellIntakeRelay
            .bind(to: viewModel.intakeRelay)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    guard let self else { return }
                    
                    let mealType = viewModel.mealTimeRelay.value
                    let consumedAt = Date().toString(format: "yyyy-MM-dd'T'HH:mm:ss")
                    let mealTypeString = mealType.rawValue
                    if let diet = viewModel.dietFoodsRelay.value[mealTypeString] {
                        let dietFoods: [DietFoodRequest] = diet.items.map { food in
                            let intake = self.addedFoodListView.cellIntakeRelay.value[food.id] ?? food.intake
                            return DietFoodRequest(foodId: food.id, intake: intake)
                        }
                        guard let userId = viewModel.getUserId() else { return }

                        if viewModel.currentFoodsRelay.value?.id == -1 {
                            Task { [weak self] in
                                await self?.viewModel.createDiet(
                                    mealType: mealType,
                                    consumedAt: consumedAt,
                                    dietFoods: dietFoods,
                                    userId: userId
                                )
                            }
                        } else {
                            Task { [weak self] in
                                await self?.viewModel.updateDiet(
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
                guard let userId = viewModel.getUserId() else { return }
                if let diet = viewModel.dietFoodsRelay.value[mealTypeString] {
                    let alert = UIAlertController(
                        title: "식단 삭제",
                        message: "식단을 삭제하시겠습니까?",
                        preferredStyle: .alert
                    )
                    
                    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                        Task { [weak self] in
                            await self?.viewModel.deleteDiet(dietId: diet.id, userId: userId)
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
        
        viewModel.saveDietSuccessRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        if viewModel.dataChangedRelay.value {
            let alert = UIAlertController(
                title: "알림",
                message: "변경된 식단이 저장되지 않았습니다. 나가시겠습니까?",
                preferredStyle: .alert
            )
            
            let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                guard let self else { return }
                
                goToBack()
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            goToBack()
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private static let mealDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일 '식단'"
        return formatter
    }()

    private func formattedMealDate(_ date: Date) -> String {
        return Self.mealDateFormatter.string(from: date)
    }
    
    private func goToBack() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
}
