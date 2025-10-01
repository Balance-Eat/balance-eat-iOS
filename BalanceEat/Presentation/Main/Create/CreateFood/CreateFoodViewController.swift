//
//  CreateFoodViewController.swift
//  BalanceEat
//
//  Created by 김견 on 9/16/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import UUIDV7

final class CreateFoodViewController: BaseViewController<CreateFoodViewModel> {
    private let nameRelay = BehaviorRelay(value: "")
    private let amountRelay: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private let unitRelay = BehaviorRelay(value: "")
    private let carbonRelay: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private let proteinRelay: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private let fatRelay: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    private let brandNameRelay = BehaviorRelay(value: "")
    
    let createdFoodRelay: BehaviorRelay<FoodData?> = BehaviorRelay(value: nil)
    
    private let foodNameInputField = InputFieldWithIcon(placeholder: "", isNumber: false)
    private lazy var foodNameTitledInfoView = TitledInputInfoView(title: "음식 이름", inputView: foodNameInputField, useBalanceEatWrapper: false)
    
    private let brandNameInputField = InputFieldWithIcon(placeholder: "", isNumber: false)
    private lazy var brandNameTitledInfoView = TitledInputInfoView(title: "브랜드/제조사 (선택)", inputView: brandNameInputField, useBalanceEatWrapper: false)
    
    private lazy var basicInfoTitledContainerView: TitledContainerView = {
        let stack = UIStackView(arrangedSubviews: [foodNameTitledInfoView, brandNameTitledInfoView])
        stack.axis = .vertical
        stack.spacing = 16
        return TitledContainerView(icon: UIImage(systemName: "info.circle"), title: "기본 정보", contentView: stack)
    }()
    
    private let amountInputField = InputFieldWithIcon(placeholder: "", isNumber: true)
    private lazy var amountTitledInfoView = TitledInputInfoView(title: "제공량", inputView: amountInputField, useBalanceEatWrapper: false)
    
    private let unitInputField = InputFieldWithIcon(placeholder: "", isNumber: false)
    private lazy var unitTitledInfoView = TitledInputInfoView(title: "단위", inputView: unitInputField, useBalanceEatWrapper: false)
    
    private let unitPickerCategories = ["g", "ml"]
    
    private lazy var servingSizeInfoTitledContainerView: TitledContainerView = {
        let infoStack = UIStackView(arrangedSubviews: [amountTitledInfoView, unitTitledInfoView])
        infoStack.axis = .horizontal
        infoStack.spacing = 16
        infoStack.distribution = .fillEqually
        
        let guideLabel = UILabel()
        guideLabel.numberOfLines = 0
        let fullText = "💡 예시: 100g, 1개, 1컵, 1공기 등 일반적으로 섭취하는 기준량을 입력하세요"
        let attrText = NSMutableAttributedString(string: fullText, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)])
        if let range = fullText.range(of: "예시") {
            attrText.addAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .bold)], range: NSRange(range, in: fullText))
        }
        guideLabel.attributedText = attrText
        
        let guideContainer = UIView()
        guideContainer.backgroundColor = .systemGray6
        guideContainer.layer.cornerRadius = 6
        guideContainer.clipsToBounds = true
        guideContainer.addSubview(guideLabel)
        guideLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        let mainStack = UIStackView(arrangedSubviews: [infoStack, guideContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        
        return TitledContainerView(icon: UIImage(systemName: "scalemass"), title: "1회 제공량", contentView: mainStack)
    }()
    
    private let calorieInputField = InputFieldWithIcon(placeholder: "")
    private lazy var calorieTitledInfoView = TitledInputInfoView(title: "칼로리 (kcal)", inputView: calorieInputField, useBalanceEatWrapper: false)
    
    private let carbonInputField = InputFieldWithIcon(placeholder: "")
    private lazy var carbonTitledInfoView = TitledInputInfoView(title: "탄수화물 (g)", inputView: carbonInputField, useBalanceEatWrapper: false)
    
    private let proteinInputField = InputFieldWithIcon(placeholder: "")
    private lazy var proteinTitledInfoView = TitledInputInfoView(title: "단백질 (g)", inputView: proteinInputField, useBalanceEatWrapper: false)
    
    private let fatInputField = InputFieldWithIcon(placeholder: "")
    private lazy var fatTitledInfoView = TitledInputInfoView(title: "지방 (g)", inputView: fatInputField, useBalanceEatWrapper: false)
    
    private lazy var nutiritionInfoTitledContainerView: TitledContainerView = {
        let nutritionStackView = UIStackView(arrangedSubviews: [carbonTitledInfoView, proteinTitledInfoView, fatTitledInfoView])
        nutritionStackView.axis = .horizontal
        nutritionStackView.spacing = 16
        nutritionStackView.distribution = .fillEqually
        
        let guideLabel = UILabel()
        guideLabel.numberOfLines = 0
        let fullText = "💡 팁: 포장지의 영양성분표나 온라인 영양 정보를 참고하세요."
        let attrText = NSMutableAttributedString(string: fullText, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)])
        if let range = fullText.range(of: "팁") {
            attrText.addAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .bold)], range: NSRange(range, in: fullText))
        }
        guideLabel.attributedText = attrText
        
        let guideContainer = UIView()
        guideContainer.backgroundColor = .systemGray6
        guideContainer.layer.cornerRadius = 6
        guideContainer.clipsToBounds = true
        guideContainer.addSubview(guideLabel)
        guideLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        let mainStackView = UIStackView(arrangedSubviews: [nutritionStackView, guideContainer])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        return TitledContainerView(icon: UIImage(systemName: "chart.bar.xaxis"), title: "영양성분 정보", contentView: mainStackView)
    }()
    
    private let willCreateFoodPreviewView = WillCreateFoodPreviewView()
    
    private let createButton = TitledButton(
        title: "음식 추가하기",
        image: UIImage(systemName: "square.and.arrow.down"),
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.5)]
        )
    )
    
    private let resetButton = TitledButton(
        title: "입력 내용 초기화",
        image: UIImage(systemName: "arrow.clockwise"),
        style: .init(
            backgroundColor: .white,
            titleColor: .black,
            borderColor: .lightGray.withAlphaComponent(0.6),
            gradientColors: nil
        )
    )
    
    
    init() {
        let foodRepository = FoodRepository()
        let foodUseCase = FoodUseCase(repository: foodRepository)
        let vm = CreateFoodViewModel(foodUseCase: foodUseCase)
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
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        createButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        [basicInfoTitledContainerView, servingSizeInfoTitledContainerView, nutiritionInfoTitledContainerView, willCreateFoodPreviewView, createButton, resetButton].forEach(mainStackView.addArrangedSubview)
        
        unitInputField.textField.delegate = self
    }
    
    private func setBinding() {
        foodNameInputField.textObservable
            .map { $0 ?? "" }
            .bind(to: nameRelay)
            .disposed(by: disposeBag)
        
        amountInputField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: amountRelay)
            .disposed(by: disposeBag)
        
        unitInputField.textObservable
            .map { $0 ?? "" }
            .bind(to: unitRelay)
            .disposed(by: disposeBag)
        
        carbonInputField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: carbonRelay)
            .disposed(by: disposeBag)
        
        proteinInputField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: proteinRelay)
            .disposed(by: disposeBag)
        
        fatInputField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: fatRelay)
            .disposed(by: disposeBag)
        
        brandNameInputField.textObservable
            .map { $0 ?? "" }
            .bind(to: brandNameRelay)
            .disposed(by: disposeBag)
        
        nameRelay
            .bind(to: willCreateFoodPreviewView.foodNameRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(carbonRelay, proteinRelay, fatRelay)
            .map { (carbon, protein, fat) in
                let carbonCal = carbon * 4
                let proteinCal = protein * 4
                let fatCal = fat * 9
                return Int(carbonCal + proteinCal + fatCal)
            }
            .bind(to: willCreateFoodPreviewView.calorieRelay)
            .disposed(by: disposeBag)
        
        calorieInputField.textObservable
            .map { Int($0 ?? "") ?? 0 }
            .bind(to: willCreateFoodPreviewView.calorieRelay)
            .disposed(by: disposeBag)
        
        carbonInputField.textObservable
            .map { Int($0 ?? "") ?? 0 }
            .bind(to: willCreateFoodPreviewView.carbonRelay)
            .disposed(by: disposeBag)
        
        proteinInputField.textObservable
            .map { Int($0 ?? "") ?? 0 }
            .bind(to: willCreateFoodPreviewView.proteinRelay)
            .disposed(by: disposeBag)
        
        fatInputField.textObservable
            .map { Int($0 ?? "") ?? 0 }
            .bind(to: willCreateFoodPreviewView.fatRelay)
            .disposed(by: disposeBag)
        
        amountInputField.textObservable
            .map { Int($0 ?? "") ?? 0 }
            .bind(to: willCreateFoodPreviewView.amountRelay)
            .disposed(by: disposeBag)
        
        unitInputField.textObservable
            .map { $0 ?? "" }
            .bind(to: willCreateFoodPreviewView.unitRelay)
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    guard let self else { return }
                    
                    let name = nameRelay.value
                    let servingSize = amountRelay.value
                    let unit = unitRelay.value
                    let carbohydrates = carbonRelay.value
                    let protein = proteinRelay.value
                    let fat = fatRelay.value
                    let brand = brandNameRelay.value
                    
                    
                    let createFoodDTO = CreateFoodDTO(
                        uuid: UUID.uuidV7String(),
                        name: name,
                        servingSize: servingSize,
                        unit: unit,
                        carbohydrates: carbohydrates,
                        protein: protein,
                        fat: fat,
                        brand: brand == "" ? "없음" : brand
                    )
                
                Task {
                    await self.viewModel.createFood(createFoodDTO: createFoodDTO)
                }
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                [foodNameInputField, brandNameInputField, calorieInputField, carbonInputField, proteinInputField, fatInputField, amountInputField, unitInputField].forEach {
                    $0.setText("")
                    $0.textField.sendActions(for: .editingChanged)
                }
                
                foodNameInputField.setText("")
                brandNameInputField.setText("")
                calorieInputField.setText("")
                carbonInputField.setText("")
                proteinInputField.setText("")
                fatInputField.setText("")
                amountInputField.setText("")
                unitInputField.setText("")
            })
            .disposed(by: disposeBag)
        
        let isInValidInputRelay = BehaviorRelay(value: false)
        
        Observable.combineLatest(
            foodNameInputField.textObservable,
            carbonInputField.textObservable,
            proteinInputField.textObservable,
            fatInputField.textObservable,
            amountInputField.textObservable,
            unitInputField.textObservable
        ) { name, carbon, protein, fat, amount, unit -> Bool in
                        
            let isNameEmpty = name?.isEmpty ?? true
            let isCarbonEmpty = carbon?.isEmpty ?? true
            let isProteinEmpty = protein?.isEmpty ?? true
            let isFatEmpty = fat?.isEmpty ?? true
            let isAmountEmpty = amount?.isEmpty ?? true
            let isUnitEmpty = unit?.isEmpty ?? true
            
            return isNameEmpty || isCarbonEmpty || isProteinEmpty || isFatEmpty || isAmountEmpty || isUnitEmpty
        }
        .bind(to: isInValidInputRelay)
        .disposed(by: disposeBag)
        
        isInValidInputRelay
            .map { !$0 }
            .bind(to: createButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        isInValidInputRelay
            .bind(to: willCreateFoodPreviewView.rx.isHidden)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            foodNameInputField.textObservable,
            calorieInputField.textObservable,
            carbonInputField.textObservable,
            proteinInputField.textObservable,
            fatInputField.textObservable,
            amountInputField.textObservable,
            unitInputField.textObservable
        ) { name, calorie, carbon, protein, fat, amount, unit -> Bool in
            
            
            let isNameEmpty = name?.isEmpty ?? true
            let isCalorieEmpty = calorie?.isEmpty ?? true
            let isCarbonEmpty = carbon?.isEmpty ?? true
            let isProteinEmpty = protein?.isEmpty ?? true
            let isFatEmpty = fat?.isEmpty ?? true
            let isAmountEmpty = amount?.isEmpty ?? true
            let isUnitEmpty = unit?.isEmpty ?? true
            
            return isNameEmpty && isCalorieEmpty && isCarbonEmpty && isProteinEmpty && isFatEmpty && isAmountEmpty && isUnitEmpty
        }
        .bind(to: resetButton.rx.isHidden)
        .disposed(by: disposeBag)
        
        viewModel.createFoodResultRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                
                createdFoodRelay.accept(result)
                dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func showUnitPicker() {
        let alert = UIAlertController(title: "단위 선택", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        
        let picker = UIPickerView(frame: CGRect(x: 0, y: 30, width: 270, height: 140))
        picker.dataSource = self
        picker.delegate = self
        
        if let text = unitInputField.textField.text,
           let index = unitPickerCategories.firstIndex(of: text) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "완료", style: .default, handler: { [weak self] _ in
            let selectedRow = picker.selectedRow(inComponent: 0)
            self?.unitInputField.textField.text = self?.unitPickerCategories[selectedRow]
            self?.unitInputField.textField.sendActions(for: .editingChanged)
        }))
        
        self.present(alert, animated: true)
    }
}

extension CreateFoodViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == unitInputField.textField {
            showUnitPicker()
            return false
        }
        return true
    }
}

extension CreateFoodViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        unitPickerCategories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        unitPickerCategories[row]
    }
}

final class WillCreateFoodPreviewView: UIView {
    let foodNameRelay: BehaviorRelay<String> = .init(value: "")
    let calorieRelay: BehaviorRelay<Int> = .init(value: 0)
    let carbonRelay: BehaviorRelay<Int> = .init(value: 0)
    let proteinRelay: BehaviorRelay<Int> = .init(value: 0)
    let fatRelay: BehaviorRelay<Int> = .init(value: 0)
    let amountRelay: BehaviorRelay<Int> = .init(value: 0)
    let unitRelay: BehaviorRelay<String> = .init(value: "")
    private let disposeBag = DisposeBag()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGreen
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.text = "추가될 음식 미리보기"
        return label
    }()
    
    private let foodNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .calorieText
        return label
    }()
    private let carbonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .carbonText
        return label
    }()
    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .proteinText
        return label
    }()
    private let fatLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let nutritionContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.systemGreen.cgColor
        
        let titleStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
            stackView.axis = .horizontal
            stackView.spacing = 8
            return stackView
        }()
        
        let nutritionHorizontalStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [calorieLabel, carbonLabel, proteinLabel, fatLabel])
            stackView.axis = .horizontal
            stackView.spacing = 8
            return stackView
        }()
        
        let nutritionMainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [foodNameLabel, nutritionHorizontalStackView, amountLabel])
            stackView.axis = .vertical
            stackView.spacing = 8
            return stackView
        }()
        
        nutritionContainerView.addSubview(nutritionMainStackView)
        
        [titleStackView, nutritionContainerView].forEach { addSubview($0) }
        
        titleStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(24)
        }
        
        nutritionMainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        nutritionContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(24)
        }
    }
    
    private func setBinding() {
        foodNameRelay
            .bind(to: foodNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        calorieRelay
            .map { "\($0)kcal" }
            .bind(to: calorieLabel.rx.text)
            .disposed(by: disposeBag)
        
        carbonRelay
            .map { "탄 \($0)g" }
            .bind(to: carbonLabel.rx.text)
            .disposed(by: disposeBag)
        
        proteinRelay
            .map { "단 \($0)g" }
            .bind(to: proteinLabel.rx.text)
            .disposed(by: disposeBag)
        
        fatRelay
            .map { "지 \($0)g" }
            .bind(to: fatLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(amountRelay, unitRelay)
            .subscribe(onNext: { [weak self] amount, unit in
                guard let self else { return }
                amountLabel.text = "\(amount)\(unit) 기준"
            })
            .disposed(by: disposeBag)
    }
}
