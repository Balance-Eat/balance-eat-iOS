//
//  EditBasicInfoViewController.swift
//  BalanceEat
//
//  Created by 김견 on 10/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditBasicInfoViewController: BaseViewController<EditBasicInfoViewModel> {
    private let editNameField = EditNameField()
    private let maleButton = SelectableTitledButton(
        title: "남성",
        style: .init(
            backgroundColor: .white,
            titleColor: .black,
            borderColor: .lightGray.withAlphaComponent(0.4),
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.1),
            selectedTitleColor: .blue,
            selectedBorderColor: .blue,
            selectedGradientColors: nil
        )
    )
    private let femaleButton = SelectableTitledButton(
        title: "여성",
        style: .init(
            backgroundColor: .white,
            titleColor: .black,
            borderColor: .lightGray.withAlphaComponent(0.4),
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.1),
            selectedTitleColor: .blue,
            selectedBorderColor: .blue,
            selectedGradientColors: nil
        )
    )
    private let editAgeField = EditAgeField()
    private lazy var editHeightField = EditHeightField()
    private lazy var bmiView = BMIView()
    
    private let saveButton = MenuSaveButton()
    
    private let resetButton = MenuResetButton()
    
    private let menuEditedWarningView = MenuEditedWarningView()
    
    private var bottomConstraint: Constraint?
    
    private let nameRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    private let genderRelay: BehaviorRelay<Gender> = BehaviorRelay(value: .none)
    private let ageRelay: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    private let heightRelay: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    
    private let valueChangedRelay = BehaviorRelay<Bool>(value: false)
    
    override init(viewModel: EditBasicInfoViewModel) {
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
        
        let editNameFieldContentView = EditDataContentView(
            systemImageString: "person",
            imageBackgroundColor: .systemBlue,
            titleText: "이름",
            subtitleText: "앱에서 사용할 이름을 설정하세요.",
            subView: editNameField
        )
        editNameField.setText(text: viewModel.userRelay.value?.name ?? "")
        
        let genderButtons = [maleButton, femaleButton]
        
        for button in genderButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self, weak button] isSelected in
                    guard let self = self, let button = button else { return }
                    if isSelected {
                        genderButtons.forEach {
                            if $0 != button { $0.isSelectedRelay.accept(false) }
                        }
                        self.genderRelay.accept(button === maleButton ? .male : .female)
                    } else {
                        self.genderRelay.accept(.none)
                    }
                })
                .disposed(by: disposeBag)
        }
        
        let genderStackView = UIStackView(arrangedSubviews: genderButtons)
        genderStackView.axis = .horizontal
        genderStackView.distribution = .fillEqually
        genderStackView.spacing = 8
        
        let editGenderContentView = EditDataContentView(
            systemImageString: "person.2",
            imageBackgroundColor: .purple.withAlphaComponent(0.4),
            titleText: "성별",
            subtitleText: "사용자의 성별을 설정하세요.",
            subView: genderStackView
        )
        
        if viewModel.userRelay.value?.gender == .male {
            maleButton.isSelectedRelay.accept(true)
        } else {
            femaleButton.isSelectedRelay.accept(true)
        }
        
        let editAgeContentView = EditDataContentView(
            systemImageString: "calendar",
            imageBackgroundColor: .systemGreen,
            titleText: "나이",
            subtitleText: "기초대사량 계산에 사용됩니다.",
            subView: editAgeField
        )
        editAgeField.setText(text: String(viewModel.userRelay.value?.age ?? 0))
        
        let heightStackView = UIStackView(arrangedSubviews: [editHeightField, bmiView])
        heightStackView.axis = .vertical
        heightStackView.spacing = 16
        
        let editHeightContentView = EditDataContentView(
            systemImageString: "ruler",
            imageBackgroundColor: .red,
            titleText: "키",
            subtitleText: "BMI 계산과 칼로리 산출에 사용됩니다.",
            subView: heightStackView
        )
        editHeightField.setText(text: String(format: "%.1f", viewModel.userRelay.value?.height ?? 0))
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        let menuTipView = MenuTipView(
            title: "정보 활용 안내",
            menuTips: [
                MenuTipData(
                    title: "🧮 칼로리 계산:",
                    description: """
                    성별, 나이, 키, 체중을 이용한 기초대사량 산출
                    """
                ),
                MenuTipData(
                    title: "📊 건강 지표:",
                    description: """
                    BMI, 권장 영양소 비율 등 개인 맞춤 정보
                    """
                ),
                MenuTipData(
                    title: "🎯 목표 설정:",
                    description: """
                    개인 특성에 맞는 현실적인 목표 제안
                    """
                ),
                MenuTipData(
                    title: "📈 진행 추적:",
                    description: """
                    연령과 성별에 따른 적절한 진행 속도 안내
                    """
                )
            ]
        )
        
        [editNameFieldContentView, editGenderContentView, editAgeContentView, editHeightContentView, saveButton, resetButton, menuEditedWarningView, menuTipView].forEach(mainStackView.addArrangedSubview(_:))
        
        
        navigationItem.title = "기본 정보 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setBinding() {
        editNameField.textRelay
            .bind(to: nameRelay)
            .disposed(by: disposeBag)
        
        editAgeField.textRelay
            .map { Int($0) ?? 0 }
            .bind(to: ageRelay)
            .disposed(by: disposeBag)
        
        editHeightField.textRelay
            .map { Double($0) ?? 0 }
            .bind(to: heightRelay)
            .disposed(by: disposeBag)
        
        heightRelay
            .bind(to: bmiView.heightRelay)
            .disposed(by: disposeBag)
        
        viewModel.userRelay
            .bind(to: bmiView.userDataRelay)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                guard let userData = viewModel.userRelay.value else {
                    return
                }
                
                let editedName = nameRelay.value
                let editedGender = genderRelay.value
                let editedAge = ageRelay.value
                let editedHeight = heightRelay.value
                
                let userDTO = UserDTO(
                    id: userData.id ,
                    uuid: userData.uuid,
                    name: editedName,
                    gender: editedGender,
                    age: editedAge,
                    height: editedHeight,
                    weight: userData.weight,
                    goalType: userData.goalType,
                    email: userData.email,
                    activityLevel: userData.activityLevel,
                    smi: userData.smi,
                    fatPercentage: userData.fatPercentage,
                    targetWeight: userData.targetWeight,
                    targetCalorie: userData.targetCalorie,
                    targetSmi: userData.targetSmi,
                    targetFatPercentage: userData.targetFatPercentage,
                    targetCarbohydrates: userData.targetCarbohydrates,
                    targetProtein: userData.targetProtein,
                    targetFat: userData.targetFat,
                    providerId: userData.providerId,
                    providerType: userData.providerType
                )
                
                Task {
                    await self.viewModel.updateUser(userDTO: userDTO)
                }
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                guard let userData = viewModel.userRelay.value else { return }
                
                editNameField.setText(text: userData.name)
                
                if userData.gender == .male {
                    maleButton.isSelectedRelay.accept(true)
                } else {
                    femaleButton.isSelectedRelay.accept(true)
                }
                
                editAgeField.setText(text: String(userData.age))
                editHeightField.setText(text: String(userData.height))
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(nameRelay, genderRelay, ageRelay, heightRelay, viewModel.userRelay) { name, gender, age, height, userData in
            
            let isNameMaintained = name == userData?.name
            let isGenderMaintained = gender == userData?.gender
            let isAgeMaintained = age == userData?.age
            let isHeightMaintained = height == userData?.height
            
            return isNameMaintained && isGenderMaintained && isAgeMaintained && isHeightMaintained
            
        }
        .bind(to: valueChangedRelay)
        .disposed(by: disposeBag)
        
        valueChangedRelay
            .map { !$0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        valueChangedRelay
            .bind(to: menuEditedWarningView.rx.isHidden)
            .disposed(by: disposeBag)
        
        valueChangedRelay
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

final class EditNameField: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름"
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray4
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    let textRelay: BehaviorRelay<String> = .init(value: "")
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
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor
        
        [textField, textCountLabel].forEach(addSubview(_:))
        
        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }
        
        textCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing)
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }
                
                let pattern = "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]"
                        let filteredText = text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                        
                        
                
                let limitedText = String(filteredText.prefix(15))
                
                if self.textField.text != limitedText {
                    self.textField.text = limitedText
                }
                
                let textCount = "\(limitedText.count)/15"
                self.textCountLabel.text = textCount
                
                textRelay.accept(limitedText)
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.layer.borderColor = UIColor.systemBlue.cgColor
            })
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.layer.borderColor = UIColor.systemGray4.cgColor
            })
            .disposed(by: disposeBag)
    }
    
    func setText(text: String) {
        textField.text = text
        textField.sendActions(for: .editingChanged)
    }
}

final class EditAgeField: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "나이"
        textField.clearButtonMode = .whileEditing
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        return textField
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "세"
        return label
    }()
    
    let textRelay: BehaviorRelay<String> = .init(value: "")
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
                
                var limitedText: String = text
                if text.count > 3 {
                    limitedText = String(text.prefix(3))
                    self.textField.text = limitedText
                }
                
                textRelay.accept(limitedText)
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.layer.borderColor = UIColor.systemBlue.cgColor
            })
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.layer.borderColor = UIColor.systemGray4.cgColor
            })
            .disposed(by: disposeBag)
    }
    
    func setText(text: String) {
        textField.text = text
        textField.sendActions(for: .editingChanged)
    }
}

final class EditHeightField: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "키"
        textField.clearButtonMode = .whileEditing
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        return textField
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "cm"
        return label
    }()
    
    let textRelay: BehaviorRelay<String> = .init(value: "")
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
                
                var limitedText: String = text
                if text.count > 3 {
                    limitedText = String(text.prefix(3))
                    self.textField.text = limitedText
                }
                
                textRelay.accept(limitedText)
            })
            .disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.layer.borderColor = UIColor.systemBlue.cgColor
            })
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.layer.borderColor = UIColor.systemGray4.cgColor
            })
            .disposed(by: disposeBag)
    }
    
    func setText(text: String) {
        textField.text = text
        textField.sendActions(for: .editingChanged)
    }
}

final class BMIView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 BMI"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let currentWeightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .red
        return label
    }()
    private let evaluationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    private let bmiSourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.text = "BMI 기준: 세계보건기구(WHO) 권장 지침 참고"
        return label
    }()
    private let sourceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("출처 보기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.addTarget(nil, action: #selector(openSource), for: .touchUpInside)
        return button
    }()
    
    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    let heightRelay: BehaviorRelay<Double> = .init(value: 0)
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
        self.backgroundColor = .red.withAlphaComponent(0.05)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.withAlphaComponent(0.1).cgColor
        
        let leftStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, currentWeightLabel])
            stackView.axis = .vertical
            stackView.spacing = 4
            return stackView
        }()
        
        let rightStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [valueLabel, evaluationLabel])
            stackView.axis = .vertical
            stackView.spacing = 4
            stackView.alignment = .trailing
            return stackView
        }()
        
        [leftStackView, rightStackView, bmiSourceLabel, sourceButton].forEach(addSubview(_:))
        
        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(12)
        }
        
        bmiSourceLabel.snp.makeConstraints { make in
            make.top.equalTo(rightStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(16)
        }
        
        sourceButton.snp.makeConstraints { make in
            make.top.equalTo(bmiSourceLabel.snp.bottom)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setBinding() {
        Observable.combineLatest(heightRelay, userDataRelay)
            .subscribe(onNext: { [weak self] (height, userData) in
                guard let self else { return }
                guard let weight = userData?.weight else { return }
                
                currentWeightLabel.text = "현재 체중 \(String(format: "%.1f", userData?.weight ?? 0))kg 기준"
                let bmi = weight / (pow(height, 2) * 0.0001)
                
                valueLabel.text = height == 0 ? "-" : String(format: "%.1f", bmi)
                
                if bmi < 18.5 {
                    evaluationLabel.text = "저체중"
                } else if bmi >= 18.5 && bmi <= 24.9 {
                    evaluationLabel.text = "정상"
                } else if bmi >= 25 && bmi <= 29.9 {
                    evaluationLabel.text = "과체중"
                } else {
                    evaluationLabel.text = "비만"
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    @objc private func openSource() {
        guard let url = URL(string: "https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight") else { return }
        UIApplication.shared.open(url)
    }
}
