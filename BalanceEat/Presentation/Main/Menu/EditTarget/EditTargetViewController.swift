//
//  EditTargetViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/18/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditTargetViewController: BaseViewController<EditTargetViewModel> {
    private let userData: UserData
    
    private let weightEditTargetItemView = EditTargetItemView(editTargetItemType: .weight)
    private let smiEditTargetItemView = EditTargetItemView(editTargetItemType: .smi)
    private let fatPercentageEditTargetItemView = EditTargetItemView(editTargetItemType: .fatPercentage)

    private let saveButton = MenuSaveButton()
    
    private let resetButton = MenuResetButton()
    
    private let menuEditedWarningView: MenuEditedWarningView = {
        let view = MenuEditedWarningView()
        view.isHidden = true
        return view
    }()
    
    private let showTargetGuideButton = TargetGuideButton()
    
    private var bottomConstraint: Constraint?
    
    private let currentWeightRelay = BehaviorRelay<Double?>(value: nil)
    private let targetWeightRelay = BehaviorRelay<Double?>(value: nil)
    private let currentSMIRelay = BehaviorRelay<Double?>(value: 0)
    private let targetSMIRelay = BehaviorRelay<Double?>(value: 0)
    private let currentFatPercentageRelay = BehaviorRelay<Double?>(value: 0)
    private let targetFatPercentageRelay = BehaviorRelay<Double?>(value: 0)
    private let carbonRelay = BehaviorRelay<Double>(value: 0)
    private let proteinRelay = BehaviorRelay<Double>(value: 0)
    private let fatRelay = BehaviorRelay<Double>(value: 0)
    
    private let valueOfAllChangedRelay = BehaviorRelay<Bool>(value: false)
    private let nutritionValueChangedRelay = BehaviorRelay<Bool>(value: false)
        
    init(userData: UserData, viewModel: EditTargetViewModel) {
        self.userData = userData
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setBinding()
        setUpKeyboardDismissGesture()
        observeKeyboard()
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
            make.height.equalTo(0)
        }
        
        scrollView.snp.makeConstraints { make in
            self.bottomConstraint = make.bottom.equalToSuperview().inset(0).constraint
        }
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        let currentWeightText = userData.weight.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(userData.weight))
        : String(userData.weight)
        weightEditTargetItemView.setCurrentText(currentWeightText)
        
        
        let targetWeightText = userData.targetWeight.truncatingRemainder(dividingBy: 1) == 0
        ? String(Int(userData.targetWeight))
        : String(userData.targetWeight)
        weightEditTargetItemView.setTargetText(targetWeightText)
        
        
        if let currentSmiValue = userData.smi {
            let text = currentSmiValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentSmiValue))
                : String(currentSmiValue)
            smiEditTargetItemView.setCurrentText(text)
        }

        if let targetSmiValue = userData.targetSmi {
            let text = targetSmiValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetSmiValue))
                : String(targetSmiValue)
            smiEditTargetItemView.setTargetText(text)
        }

        if let currentFatPercentageValue = userData.fatPercentage {
            let text = currentFatPercentageValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentFatPercentageValue))
                : String(currentFatPercentageValue)
            fatPercentageEditTargetItemView.setCurrentText(text)
        }

        if let targetFatPercentageValue = userData.targetFatPercentage {
            let text = targetFatPercentageValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetFatPercentageValue))
                : String(targetFatPercentageValue)
            fatPercentageEditTargetItemView.setTargetText(text)
        }
        
        let goalSummaryView = GoalSummaryView(
            currentWeightRelay: currentWeightRelay,
            targetWeightRelay: targetWeightRelay,
            currentSMIRelay: currentSMIRelay,
            targetSMIRelay: targetSMIRelay,
            currentFatPercentageRelay: currentFatPercentageRelay,
            targetFatPercentageRelay: targetFatPercentageRelay
        )
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        let measurementTipsView = MenuTipView(
            title: "측정 및 업데이트 팁",
            menuTips: [
                MenuTipData(
                    title: "📅 측정 주기:",
                    description: """
        • 체중: 매일 (같은 시간)
        • 골격근량: 월 1-2회
        • 체지방률: 월 1-2회
        """
                ),
                MenuTipData(
                    title: "🎯 목표 수정:",
                    description: """
        • 진행 상황에 맞춰 조정
        • 급격한 변화는 피하기
        • 전문가 상담 권장
        """
                )
            ]
        )
        
        let weightEditTargetContentView = EditDataContentView(
            systemImageString: EditTargetItemType.weight.systemImage,
            imageBackgroundColor: EditTargetItemType.weight.color,
            titleText: EditTargetItemType.weight.title,
            subtitleText: EditTargetItemType.weight.subtitle,
            subView: weightEditTargetItemView
        )
        let smiEditTargetContentView = EditDataContentView(
            systemImageString: EditTargetItemType.smi.systemImage,
            imageBackgroundColor: EditTargetItemType.smi.color,
            titleText: EditTargetItemType.smi.title,
            subtitleText: EditTargetItemType.smi.subtitle,
            subView: smiEditTargetItemView
        )
        let fatPercentageEditTargetContentView = EditDataContentView(
            systemImageString: EditTargetItemType.fatPercentage.systemImage,
            imageBackgroundColor: EditTargetItemType.fatPercentage.color,
            titleText: EditTargetItemType.fatPercentage.title,
            subtitleText: EditTargetItemType.fatPercentage.subtitle,
            subView: fatPercentageEditTargetItemView
        )

        [showTargetGuideButton, weightEditTargetContentView, smiEditTargetContentView, fatPercentageEditTargetContentView, goalSummaryView, saveButton, resetButton, menuEditedWarningView, measurementTipsView].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        menuEditedWarningView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        navigationItem.title = "목표 설정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
    }
    
    private func setBinding() {
        weightEditTargetItemView.currentText
            .map { text -> Double? in
                Double(text ?? "")
            }
            .bind(to: currentWeightRelay)
            .disposed(by: disposeBag)
        
        weightEditTargetItemView.targetText
            .map { text -> Double? in
                Double(text ?? "")
            }
            .bind(to: targetWeightRelay)
            .disposed(by: disposeBag)
        
        smiEditTargetItemView.currentText
            .map { text -> Double? in
                Double(text ?? "")
            }
            .bind(to: currentSMIRelay)
            .disposed(by: disposeBag)
        
        smiEditTargetItemView.targetText
            .map { text -> Double? in
                Double(text ?? "")
            }
            .bind(to: targetSMIRelay)
            .disposed(by: disposeBag)
        
        fatPercentageEditTargetItemView.currentText
            .map { text -> Double? in
                Double(text ?? "")
            }
            .bind(to: currentFatPercentageRelay)
            .disposed(by: disposeBag)
        
        fatPercentageEditTargetItemView.targetText
            .map { text -> Double? in
                Double(text ?? "")
            }
            .bind(to: targetFatPercentageRelay)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(
                onNext: { [weak self] in
                    guard let self else { return }
                    
                    let currentUser = userData
                    
                    let editedCurrentWeight = currentWeightRelay.value ?? 0
                    let editedTargetWeight = targetWeightRelay.value ?? 0
                    let editedCurrentSMI = currentSMIRelay.value
                    let editedTargetSMI = targetSMIRelay.value
                    let editedCurrentFatPercentage = currentFatPercentageRelay.value
                    let editedTargetFatPercentage = targetFatPercentageRelay.value
                    let editedCarbon = carbonRelay.value
                    let editedProtein = proteinRelay.value
                    let editedFat = fatRelay.value
                    
                    let userDTO = UserDTO(
                        id: currentUser.id,
                        uuid: currentUser.uuid,
                        name: currentUser.name,
                        gender: currentUser.gender,
                        age: currentUser.age,
                        height: currentUser.height,
                        weight: editedCurrentWeight,
                        goalType: currentUser.goalType,
                        email: currentUser.email,
                        activityLevel: currentUser.activityLevel,
                        smi: editedCurrentSMI,
                        fatPercentage: editedCurrentFatPercentage,
                        targetWeight: editedTargetWeight,
                        targetCalorie: currentUser.targetCalorie,
                        targetSmi: editedTargetSMI,
                        targetFatPercentage: editedTargetFatPercentage,
                        targetCarbohydrates: editedCarbon,
                        targetProtein: editedProtein,
                        targetFat: editedFat,
                        providerId: currentUser.providerId,
                        providerType: currentUser.providerType
                    )
                    
                    Task {
                        await self.viewModel.updateUser(userDTO: userDTO)
                    }
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                weightEditTargetItemView.setCurrentText(String(userData.weight))
                weightEditTargetItemView.setTargetText(String(userData.targetWeight))
                smiEditTargetItemView.setCurrentText(String(userData.smi ?? 0))
                smiEditTargetItemView.setTargetText(String(userData.targetSmi ?? 0))
                fatPercentageEditTargetItemView.setCurrentText(String(userData.fatPercentage ?? 0))
                fatPercentageEditTargetItemView.setTargetText(String(userData.targetFatPercentage ?? 0))
            })
            .disposed(by: disposeBag)
        
        showTargetGuideButton.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                let targetGuideViewController = TargetGuideViewController()
                
                targetGuideViewController.modalPresentationStyle = .overCurrentContext
                targetGuideViewController.modalTransitionStyle = .crossDissolve
                
                present(targetGuideViewController, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            carbonRelay,
            proteinRelay,
            fatRelay
        ) { [weak self] carbon, protein, fat -> Bool in
            guard let self else { return false }
            
            let isCarbonMaintained = carbon == round(userData.targetCarbohydrates ?? 0)
            let isProteinMaintained = protein == round(userData.targetProtein ?? 0)
            let isFatMaintained = fat == round(userData.targetFat ?? 0)
            
            return isCarbonMaintained && isProteinMaintained && isFatMaintained
        }
        .bind(to: nutritionValueChangedRelay)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(
            currentWeightRelay,
            targetWeightRelay,
            currentSMIRelay,
            targetSMIRelay,
            currentFatPercentageRelay,
            targetFatPercentageRelay
        ) { [weak self] currentWeight, targetWeight, currentSMI, targetSMI, currentFatPercentage, targetFatPercentage -> Bool in
            
            guard let self else { return false }
            
            let isCurrentWeightMaintained = currentWeight == userData.weight
            let isTargetWeightMaintained = targetWeight == userData.targetWeight
            let isCurrentSMIMaintained = currentSMI == userData.smi
            let isTargetSMIMaintained = targetSMI == userData.targetSmi
            let isCurrentFatPercentageMaintained = currentFatPercentage == userData.fatPercentage
            let isTargetFatPercentageMaintained = targetFatPercentage == userData.targetFatPercentage
            
            return isCurrentWeightMaintained && isTargetWeightMaintained && isCurrentSMIMaintained && isTargetSMIMaintained && isCurrentFatPercentageMaintained && isTargetFatPercentageMaintained
        }
        .bind(to: valueOfAllChangedRelay)
        .disposed(by: disposeBag)
        
        valueOfAllChangedRelay
            .map { !$0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        valueOfAllChangedRelay
            .bind(to: menuEditedWarningView.rx.isHidden)
            .disposed(by: disposeBag)
        
        valueOfAllChangedRelay
            .bind(to: resetButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.updateUserResultRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] updateUserResult in
                guard let self else { return }
                if updateUserResult {
                    navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    private func setUpKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = frame.height
        
        bottomConstraint?.update(inset: keyboardHeight)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.update(inset: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

enum EditTargetItemType {
    case weight
    case smi
    case fatPercentage
    
    var title: String {
        switch self {
        case .weight:
            return "체중"
        case .smi:
            return "골격근량"
        case .fatPercentage:
            return "체지방률"
        }
    }
    
    var subtitle: String {
        switch self {
            case .weight:
            return "현재 체중과 목표 체중을 설정하세요"
        case .smi:
            return "근육량 목표를 설정하세요"
        case .fatPercentage:
            return "체지방률 목표를 설정하세요"
        }
    }
    
    var unit: String {
        switch self {
        case .weight:
            return "kg"
        case .smi:
            return "kg"
        case .fatPercentage:
            return "%"
        }
    }
    
    var systemImage: String {
        switch self {
        case .weight:
            return "scalemass"
        case .smi:
            return "figure.walk"
        case .fatPercentage:
            return "drop.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .weight:
            return .weight
        case .smi:
            return .SMI
        case .fatPercentage:
            return .fatPercentage
        }
    }
}

final class EditTargetItemView: UIView {
    private let editTargetItemType: EditTargetItemType
    
    private lazy var currentField = InputFieldWithIcon(placeholder: "", unit: editTargetItemType == .fatPercentage ? "%" : "kg", isFat: editTargetItemType == .fatPercentage)
    private lazy var targetField = InputFieldWithIcon(placeholder: "", unit: editTargetItemType == .fatPercentage ? "%" : "kg", isFat: editTargetItemType == .fatPercentage)
    
    var currentText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var targetText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()
    
    init(editTargetItemType: EditTargetItemType) {
        self.editTargetItemType = editTargetItemType
    
        super.init(frame: .zero)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        let mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [])
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()
        
        let currentTitledInputUserInfoView = TitledInputInfoView(title: "현재 \(editTargetItemType.title)", inputView: currentField, useBalanceEatWrapper: false)
        
        currentField.textObservable
            .bind(to: currentText)
            .disposed(by: disposeBag)
        
        let targetTitledInputUserInfoView = TitledInputInfoView(title: "목표 \(editTargetItemType.title)", inputView: targetField, useBalanceEatWrapper: false)
        
        targetField.textObservable
            .bind(to: targetText)
            .disposed(by: disposeBag)
        
        let fieldStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [currentTitledInputUserInfoView, targetTitledInputUserInfoView])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            return stackView
        }()
        
        mainStackView.addArrangedSubview(fieldStackView)
        
        let diffLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .systemGray
            label.textAlignment = .center
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            return label
        }()
        diffLabel.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        mainStackView.addArrangedSubview(diffLabel)
        
        Observable.combineLatest(currentText, targetText) { current, target -> Double? in
            guard let currentValue = Double(current ?? ""), let targetValue = Double(target ?? "") else {
                return nil
            }
            return targetValue - currentValue
        }
        .subscribe(onNext: { [weak self] (diff: Double?) in
            guard let self else { return }
            
            if let diff = diff {
                if diff > 0 {
                    diffLabel.text = String(format: "%.1f%@ 증가", diff, self.editTargetItemType.unit)
                    diffLabel.textColor = .systemBlue
                    diffLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                } else if diff < 0 {
                    diffLabel.text = String(format: "%.1f%@ 감소", abs(diff), self.editTargetItemType.unit)
                    diffLabel.textColor = .systemRed
                    diffLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                } else {
                    diffLabel.text = "변화 없음"
                    diffLabel.textColor = .systemGray
                    diffLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
                }
            } else {
                let currentString = currentText.value ?? ""
                let targetString = targetText.value ?? ""
                let title = self.editTargetItemType.title
                let labelText = (currentString.isEmpty && targetString.isEmpty) ? "\(title)을 입력해주세요." : currentString.isEmpty ? "현재 \(title)을 입력해주세요." : "목표 \(title)을 입력해주세요."
                diffLabel.text = labelText
                diffLabel.textColor = .systemGray
                diffLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
            }

        })
        .disposed(by: disposeBag)
        
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setCurrentText(_ text: String) {
        currentText.accept(text)
        currentField.setText(text)
    }

    func setTargetText(_ text: String) {
        targetText.accept(text)
        targetField.setText(text)
    }
}

final class EditNutritionInfoView: UIView {
    private let carbonField = InputFieldWithIcon(placeholder: "", unit: "g")
    private let proteinField = InputFieldWithIcon(placeholder: "", unit: "g")
    private let fatField = InputFieldWithIcon(placeholder: "", unit: "g")
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "예상 일일 소모 칼로리를 토대로 추천드리는 값입니다.\n예상 일일 소모 칼로리와 다를 수 있습니다."
        return label
    }()
    
    let carbonRelay: BehaviorRelay<Double> = .init(value: 0)
    let proteinRelay: BehaviorRelay<Double> = .init(value: 0)
    let fatRelay: BehaviorRelay<Double> = .init(value: 0)
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [])
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()
        
        let carbonTitledInputInfoView = TitledInputInfoView(title: "탄수화물", inputView: carbonField, useBalanceEatWrapper: false)
        let proteinTitledInputInfoView = TitledInputInfoView(title: "단백질", inputView: proteinField, useBalanceEatWrapper: false)
        let fatTitledInputInfoView = TitledInputInfoView(title: "지방", inputView: fatField, useBalanceEatWrapper: false)
        
        [carbonTitledInputInfoView, proteinTitledInputInfoView, fatTitledInputInfoView, calorieLabel, explanationLabel].forEach(mainStackView.addArrangedSubview(_:))
        
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setBinding() {
        carbonField.textObservable
            .map { text -> Double in
                Double(text ?? "") ?? 0
            }
            .bind(to: carbonRelay)
            .disposed(by: disposeBag)
        
        proteinField.textObservable
            .map { text -> Double in
                Double(text ?? "") ?? 0
            }
            .bind(to: proteinRelay)
            .disposed(by: disposeBag)
        
        fatField.textObservable
            .map { text -> Double in
                Double(text ?? "") ?? 0
            }
            .bind(to: fatRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(carbonRelay, proteinRelay, fatRelay)
        { carbon, protein, fat in
            let carbonCalorie = carbon * 4
            let proteinCalorie = protein * 4
            let fatCalorie = fat * 9
            
            return carbonCalorie + proteinCalorie + fatCalorie
        }
        .map { "총: \(String(format: "%.0f", $0))kcal" }
        .bind(to: calorieLabel.rx.text)
        .disposed(by: disposeBag)
    }
    
    func setCarbonText(text: String) {
        carbonField.setText(text)
        carbonField.textField.sendActions(for: .editingChanged)
    }
    
    func setProteinText(text: String) {
        proteinField.setText(text)
        proteinField.textField.sendActions(for: .editingChanged)
    }
    
    func setFatText(text: String) {
        fatField.setText(text)
        fatField.textField.sendActions(for: .editingChanged)
    }
}

final class EditNutritionField: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.textAlignment = .center
        return textField
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    let textRelay: BehaviorRelay<String> = .init(value: "")
    private let disposeBag = DisposeBag()
    
    init(placeholder: String, unit: String) {
        textField.placeholder = placeholder
        subTitleLabel.text = unit
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor
        
        [textField, subTitleLabel].forEach(addSubview(_:))
        
        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing)
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                
                if Double(text) ?? 0 >= 1000 {
                    self.textField.text = "999"
                }
                
                textRelay.accept(text)
            })
            .disposed(by: disposeBag)
    }
    
    func setText(text: String) {
        textField.text = text
        textField.sendActions(for: .editingChanged)
    }
}

final class GoalSummaryView: UIView {
    private let titleStackView: UIStackView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = "목표 요약"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill
        
        return stackView
    }()
    private lazy var targetsStackView: UIStackView = {
        let weightGoalSummaryContentView = GoalSummaryContentView(
            editTargetItemType: .weight,
            currentRelay: currentWeightRelay,
            targetRelay: targetWeightRelay
        )
        let smiGoalSummaryContentView = GoalSummaryContentView(
            editTargetItemType: .smi,
            currentRelay: currentSMIRelay,
            targetRelay: targetSMIRelay
        )
        let fatPercentageGoalSummaryContentView = GoalSummaryContentView(
            editTargetItemType: .fatPercentage,
            currentRelay: currentFatPercentageRelay,
            targetRelay: targetFatPercentageRelay
        )
        let stackView = UIStackView(arrangedSubviews: [
            weightGoalSummaryContentView,
            smiGoalSummaryContentView,
            fatPercentageGoalSummaryContentView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let currentWeightRelay: BehaviorRelay<Double?>
    private let targetWeightRelay: BehaviorRelay<Double?>
    private let currentSMIRelay: BehaviorRelay<Double?>
    private let targetSMIRelay: BehaviorRelay<Double?>
    private let currentFatPercentageRelay: BehaviorRelay<Double?>
    private let targetFatPercentageRelay: BehaviorRelay<Double?>
    
    private let disposeBag = DisposeBag()
    
    init(currentWeightRelay: BehaviorRelay<Double?>, targetWeightRelay: BehaviorRelay<Double?>, currentSMIRelay: BehaviorRelay<Double?>, targetSMIRelay: BehaviorRelay<Double?>, currentFatPercentageRelay: BehaviorRelay<Double?>, targetFatPercentageRelay: BehaviorRelay<Double?>) {
        self.currentWeightRelay = currentWeightRelay
        self.targetWeightRelay = targetWeightRelay
        self.currentSMIRelay = currentSMIRelay
        self.targetSMIRelay = targetSMIRelay
        self.currentFatPercentageRelay = currentFatPercentageRelay
        self.targetFatPercentageRelay = targetFatPercentageRelay
        super.init(frame: .zero)
        
        self.backgroundColor = .systemBlue.withAlphaComponent(0.05)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.4).cgColor
        
        [titleStackView, targetsStackView].forEach { addSubview($0) }
        
        titleStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
        }
        
        targetsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class GoalSummaryContentView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let differenceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()
    private let differenceContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    init(editTargetItemType: EditTargetItemType, currentRelay: BehaviorRelay<Double?>, targetRelay: BehaviorRelay<Double?>) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        
        iconImageView.image = UIImage(systemName: editTargetItemType.systemImage)
        iconImageView.tintColor = editTargetItemType.color
        titleLabel.text = editTargetItemType.title
        
        Observable.combineLatest(currentRelay, targetRelay)
            .subscribe(onNext: { [weak self] current, target in
                guard let self else { return }
                guard let current else { return }
                guard let target else { return }
                
                let diff = target - current

                self.changeLabel.text = "\(current.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", current) : String(current))\(editTargetItemType.unit) → \(target.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", target) : String(target))\(editTargetItemType.unit)"


                if diff > 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 증가", diff, editTargetItemType.unit)
                    self.differenceLabel.textColor = .systemBlue
                    self.differenceContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                } else if diff < 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 감소", abs(diff), editTargetItemType.unit)
                    self.differenceLabel.textColor = .systemRed
                    self.differenceContainerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                } else {
                    self.differenceLabel.text = "변화 없음"
                    self.differenceLabel.textColor = .systemGray
                    self.differenceContainerView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
                }
            })
            .disposed(by: disposeBag)

        differenceContainerView.addSubview(differenceLabel)
        
        [iconImageView, titleLabel, changeLabel, differenceContainerView].forEach { addSubview($0) }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        changeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(differenceLabel.snp.leading).offset(-16)
            make.centerY.equalToSuperview()
        }
        
        differenceLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        differenceContainerView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

