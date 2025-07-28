//
//  AddFoodViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/26/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum ServingUnitType: String {
    case serving = "인분"
    case gram = "g"
    case milliliter = "ml"
}

class AddFoodViewController: UIViewController {
    private let foodItem: FoodItem
    private let selectedServingUnitType = BehaviorRelay<ServingUnitType>(value: .serving)
    private let inputAmount = BehaviorRelay<Int>(value: 100)
    private let disposeBag = DisposeBag()
    
    init(foodItem: FoodItem) {
        self.foodItem = foodItem
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setupPopupContent()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setupPopupContent() {
        let contentView = HomeMenuContentView()
        
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
//            make.height.equalTo(400)
        }
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            label.textColor = .black
            label.text = "\(foodItem.name) 추가"
            return label
        }()
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        let closeButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.tintColor = .black
            return button
        }()
        
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        contentView.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        let servingUnitSelectPickerView = ServingUnitSelectPickerView(
            selectedServingUnitType: selectedServingUnitType.value,
            items: [
                ServingUnitSelectPickerItem(servingUnitType: .serving, isSelected: true),
                ServingUnitSelectPickerItem(servingUnitType: .gram, isSelected: false)
            ]
        )
        
        servingUnitSelectPickerView.selectedServingUnitTypeRelay
            .bind(to: selectedServingUnitType)
            .disposed(by: disposeBag)
        
        let servingUnitSelectTitledContainerView = TitledContainerView(
            title: "입력 방법",
            contentView: servingUnitSelectPickerView,
            isSmall: true,
            isShadowBackground: false
        )
        
        contentView.addSubview(servingUnitSelectTitledContainerView)
        
        servingUnitSelectTitledContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        let amountCountingView = AmountCountingView(amount: inputAmount.value)
        
        let amountCountingTitledContainerView = TitledContainerView(
            title: "중량",
            contentView: amountCountingView,
            isSmall: true,
            isShadowBackground: false
        )
            
        contentView.addSubview(amountCountingTitledContainerView)
        
        amountCountingTitledContainerView.snp.makeConstraints { make in
            make.top.equalTo(servingUnitSelectTitledContainerView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        let totalNutritionalInfoView = TotalNutritionalInfoView(title: "예상 영양정보", foodItems: [
            AddedFoodItem(foodName: foodItem.name, amount: String(foodItem.amount), calorie: foodItem.nutritionalInfo.calories, carbon: foodItem.nutritionalInfo.carbs, protein: foodItem.nutritionalInfo.protein, fat: foodItem.nutritionalInfo.fat)
        ])
        
        contentView.addSubview(totalNutritionalInfoView)
        
        totalNutritionalInfoView.snp.makeConstraints { make in
            make.top.equalTo(amountCountingTitledContainerView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setBinding() {
        
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    
}

final class ServingUnitSelectPickerView: UIView {
    private let stackView = UIStackView()
    
    let selectedServingUnitTypeRelay: BehaviorRelay<ServingUnitType>
    
    private var items: [ServingUnitSelectPickerItem] = []
    private let disposeBag = DisposeBag()
    
    init(selectedServingUnitType: ServingUnitType, items: [ServingUnitSelectPickerItem]) {
        self.selectedServingUnitTypeRelay = BehaviorRelay(value: selectedServingUnitType)
        self.items = items
        super.init(frame: .zero)
        setUpView()
        setUpItems()
        updateSelectedItem(selectedType: selectedServingUnitType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.isUserInteractionEnabled = true
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    private func setUpItems() {
        for item in items {
            stackView.addArrangedSubview(item)
            
            item.tapObservable
                .bind { [weak self] in
                    guard let self = self else { return }
                    self.selectedServingUnitTypeRelay.accept(item.servingUnitType)
                    self.updateSelectedItem(selectedType: item.servingUnitType)
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func updateSelectedItem(selectedType: ServingUnitType) {
        for item in items {
            item.setSelected(item.servingUnitType == selectedType)
        }
    }
}

final class ServingUnitSelectPickerItem: UIView {
    let servingUnitType: ServingUnitType
    private var isSelected: Bool = false
    private var titleText: String {
        switch servingUnitType {
        case .serving:
            "1인분 단위"
        case .gram:
            "중량 단위"
        case .milliliter:
            "용량 단위"
        }
    }
    private let tap: PublishSubject<Void> = .init()
    var tapObservable: Observable<Void> {
        tap.asObservable()
    }
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .mealTimePickerTitle
        return label
    }()
    
    init(servingUnitType: ServingUnitType, isSelected: Bool) {
        self.servingUnitType = servingUnitType
        self.isSelected = isSelected
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.alpha = 0.6
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.alpha = 1.0
    }
    
    private func setUpView() {
        self.isUserInteractionEnabled = true
        
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mealTimePickerBorder.cgColor
        
        titleLabel.text = titleText
        
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    private func setUpBinding() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.tap.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        self.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.mealTimePickerBorder.cgColor
        self.titleLabel.textColor = selected ? .systemBlue : .mealTimePickerTitle
    }
}

final class AmountCountingView: UIView {
    let amountRelay: BehaviorRelay<Int>
    
    private let disposeBag = DisposeBag()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .label
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    init(amount: Int) {
        self.amountRelay = BehaviorRelay<Int>(value: amount)
        super.init(frame: .zero)
        
        setUpView()
        setEvent()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        self.addSubview(textField)
        self.addSubview(minusButton)
        self.addSubview(plusButton)

        minusButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(minusButton.snp.trailing).offset(12)
            make.trailing.equalTo(plusButton.snp.leading).offset(-12)
            make.height.equalTo(40)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }

    private func setEvent() {
        minusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = max(0, self.amountRelay.value - 1)
                self.amountRelay.accept(newValue)
            })
            .disposed(by: disposeBag)

        plusButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.amountRelay.accept(self.amountRelay.value + 1)
            })
            .disposed(by: disposeBag)
    }

    private func bind() {
        amountRelay
            .map { "\($0)" }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }
}
