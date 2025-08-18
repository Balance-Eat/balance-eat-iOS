//
//  TargetInfoViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/10/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FlexLayout
import PinLayout

class TargetInfoViewController: UIViewController {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "목표를 설정해주세요."
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "맞춤형 식단 계획을 위해 목표를 명확히 해보세요."
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let currentWeightLabel = UILabel()
    
    private var targetWeightText: Observable<String?> = Observable.just(nil)
    private var selectedGoal: BehaviorRelay<GoalType?> = BehaviorRelay(value: GoalType.none)
    private var currentSMIText: Observable<String?> = Observable.just(nil)
    private var targetSMIText: Observable<String?> = Observable.just(nil)
    private var currentFatPercentageText: Observable<String?> = Observable.just(nil)
    private var targetFatPercentageText: Observable<String?> = Observable.just(nil)
    
    let inputCompleted = PublishRelay<Void>()
    private let optionalIsOpen = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(mainStackView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        let currentWeightView = self.currentWeightView()
        
        let weightInputField = InputFieldWithIcon(icon: UIImage(systemName: "scalemass")!, placeholder: "목표 체중을 입력해주세요.", unit: "kg")
        let weightInputView = TitledInputUserInfoView(title: "목표 체중", inputView: weightInputField)
        self.targetWeightText = weightInputField.textObservable
        
        let goalPickerView = GoalPickerView()
        goalPickerView.selectedGoalRelay
            .subscribe(onNext: { [weak self] goal in
                guard let self = self else { return }
                self.selectedGoal.accept(goal)
            })
            .disposed(by: disposeBag)
        let goalPickerInputView = TitledInputUserInfoView(title: "목표 유형", inputView: goalPickerView)
        
        let optionalTargetTitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 20, weight: .bold)
            label.textColor = .black
            label.text = "선택 사항 설정"
            return label
        }()
        let optionalTargetOpenButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            button.tintColor = .black
            return button
        }()
        optionalTargetOpenButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                var optionalIsOpenValue = self.optionalIsOpen.value
                optionalIsOpenValue.toggle()
                self.optionalIsOpen.accept(optionalIsOpenValue)
            })
            .disposed(by: disposeBag)
        
        let optionalTargetTitleStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [optionalTargetTitleLabel, optionalTargetOpenButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            return stackView
        }()
        
        let currentSMIInputView = InputFieldWithIcon(
            icon: UIImage(systemName: "figure.walk") ?? UIImage(),
            placeholder: "",
            unit: "kg"
        )
        let currentSMITitledInputView = TitledInputUserInfoView(title: "현재 골격근량", inputView: currentSMIInputView)
        self.currentSMIText = currentSMIInputView.textObservable
        
        let targetSMIInputView = InputFieldWithIcon(
            icon: UIImage(systemName: "target") ?? UIImage(),
            placeholder: "",
            unit: "kg"
        )
        let targetSMITitledInputView = TitledInputUserInfoView(title: "목표 골격근량", inputView: targetSMIInputView)
        self.targetSMIText = targetSMIInputView.textObservable
        
        let SMIStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [currentSMITitledInputView, targetSMITitledInputView])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            return stackView
        }()
        
        let currentFatPercentageInputView = InputFieldWithIcon(
            icon: UIImage(systemName: "drop.fill") ?? UIImage(),
            placeholder: "",
            unit: "%"
        )
        let currentFatTitledInputView = TitledInputUserInfoView(title: "현재 체지방률", inputView: currentFatPercentageInputView)
        self.currentFatPercentageText = currentFatPercentageInputView.textObservable
        
        let targetFatPercentageInputView = InputFieldWithIcon(
            icon: UIImage(systemName: "flag.fill") ?? UIImage(),
            placeholder: "",
            unit: "%"
        )
        let targetFatTitledInputView = TitledInputUserInfoView(title: "목표 체지방률", inputView: targetFatPercentageInputView)
        self.targetFatPercentageText = targetFatPercentageInputView.textObservable
        
        let fatPercentageStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [currentFatTitledInputView, targetFatTitledInputView])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            return stackView
        }()
        
        optionalIsOpen
            .subscribe(onNext: { isOpen in
                UIView.animate(withDuration: 0.3) {
                    if isOpen {
                        optionalTargetOpenButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                        SMIStackView.isHidden = false
                        fatPercentageStackView.isHidden = false
                    } else {
                        optionalTargetOpenButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                        SMIStackView.isHidden = true
                        fatPercentageStackView.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
        let nextButton = TitledButton(
            title: "다음",
            style: .init(
                backgroundColor: .systemBlue,
                titleColor: .white,
                borderColor: nil
            )
        )
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        nextButton.rx.tap
            .withLatestFrom(Observable.combineLatest(currentSMIText,
                                                     targetSMIText,
                                                     currentFatPercentageText,
                                                     targetFatPercentageText))
            .subscribe(onNext: { [weak self] currentSMI, targetSMI, currentFat, targetFat in
                guard let self = self else { return }

                let currentSMIEntered = !(currentSMI?.isEmpty ?? true)
                let targetSMIEntered = !(targetSMI?.isEmpty ?? true)
                let currentFatEntered = !(currentFat?.isEmpty ?? true)
                let targetFatEntered = !(targetFat?.isEmpty ?? true)

                if currentSMIEntered != targetSMIEntered {
                    let alert = UIAlertController(title: "입력 오류",
                                                  message: "골격근량 값이 하나만 입력되었습니다!",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                } else if currentFatEntered != targetFatEntered {
                    let alert = UIAlertController(title: "입력 오류",
                                                  message: "체지방률 값이 하나만 입력되었습니다!",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                } else {
                    self.inputCompleted.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        [currentWeightView, weightInputView, goalPickerInputView, optionalTargetTitleStackView, SMIStackView, fatPercentageStackView, nextButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        Observable.combineLatest(targetWeightText, selectedGoal) { weight, goal -> Bool in
            guard let weight = weight, let goal = goal else { return false }
            return !weight.isEmpty && goal != .none
        }
        .bind(to: nextButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(targetWeightText, selectedGoal, currentSMIText, targetSMIText, currentFatPercentageText, targetFatPercentageText)
            .subscribe(onNext: { weight, goal, currentSMI, targetSMI, currentFatPercentage, targetFatPercentage in
                var data = TutorialPageViewModel.shared.dataRelay.value
                data.targetWeight = Double(weight ?? "") ?? 0
                data.smi = Double(currentSMI ?? "") ?? 0
                data.targetSmi = Double(targetSMI ?? "") ?? 0
                data.fatPercentage = Double(currentFatPercentage ?? "") ?? 0
                data.targetFatPercentage = Double(targetFatPercentage ?? "") ?? 0
                
                TutorialPageViewModel.shared.goalTypeRelay.accept(goal ?? .none)
                TutorialPageViewModel.shared.dataRelay.accept(data)
            })
            .disposed(by: disposeBag)
    }
    
    private func currentWeightView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = "현재 체중 : "
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        
        currentWeightLabel.font = .systemFont(ofSize: 18, weight: .bold)
        currentWeightLabel.textColor = .black
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, currentWeightLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .equalCentering
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
        }
        
        return view
    }
    
    private func setUpBinding() {
        TutorialPageViewModel.shared.dataRelay
            .map { $0.weight ?? 0 }
            .distinctUntilChanged()
            .map { weight in
                String(format: "%.1fkg", weight)
            }
            .bind(to: currentWeightLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

enum GoalType {
    case diet
    case bulkUp
    case maintain
    case none
    
    var coefficient: Double {
        switch self {
        case .diet:
            return 0.8
        case .bulkUp:
            return 1.15
        case .maintain:
            return 1
        case .none:
            return 0
        }
    }
    
    var description: String {
        switch self {
        case .diet:
            return "다이어트 🔥"
        case .bulkUp:
            return "근육량 증가 💪"
        case .maintain:
            return "현재 체중 유지 ⚖️"
        case .none:
            return ""
        }
    }
}

final class GoalPickerView: UIView {
    let selectedGoalRelay = PublishRelay<GoalType>()
    
    private let rootFlex = UIView()
    
    private lazy var dietCard = GoalCardView(emoji: "🔥", title: "다이어트", subtitle: "체중 감량")
    private lazy var bulkUpCard = GoalCardView(emoji: "💪", title: "벌크업", subtitle: "근육량 증가")
    private lazy var maintainCard = GoalCardView(emoji: "⚖️", title: "유지", subtitle: "현재 체중 유지")
    
    private var selectedType: GoalType? {
        didSet {
            updateSelection(animated: true)
            if let selectedType = selectedType {
                selectedGoalRelay.accept(selectedType)
            }
        }
    }
    
    private let cardHeight: CGFloat = 80
    private let gap: CGFloat = 12
    private let cardCount: CGFloat = 3
    
    override var intrinsicContentSize: CGSize {
        let height = cardHeight * cardCount + gap * (cardCount - 1)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(rootFlex)
        rootFlex.flex.direction(.column).gap(gap).define { flex in
            flex.addItem(dietCard).height(cardHeight)
            flex.addItem(bulkUpCard).height(cardHeight)
            flex.addItem(maintainCard).height(cardHeight)
        }
    }
    
    private func setupActions() {
        [dietCard, bulkUpCard, maintainCard].forEach { card in
            card.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            card.addGestureRecognizer(tap)
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        if tappedView === dietCard { selectedType = .diet }
        else if tappedView === bulkUpCard { selectedType = .bulkUp }
        else if tappedView === maintainCard { selectedType = .maintain }
    }
    
    private func updateSelection(animated: Bool) {
        dietCard.setSelected(selectedType == .diet, animated: animated)
        bulkUpCard.setSelected(selectedType == .bulkUp, animated: animated)
        maintainCard.setSelected(selectedType == .maintain, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlex.pin.all()
        rootFlex.flex.layout(mode: .adjustHeight)
    }
}

final class GoalCardView: UIView {
    private let rootFlex = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    init(emoji: String, title: String, subtitle: String) {
        super.init(frame: .zero)
        setupView(emoji: emoji, title: title, subtitle: subtitle)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView(emoji: String, title: String, subtitle: String) {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 24)
        
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        
        addSubview(rootFlex)
        rootFlex.flex.direction(.row).alignItems(.center).padding(16).define { flex in
            flex.addItem(emojiLabel)
            flex.addItem().marginLeft(12).direction(.column).define { flex in
                flex.addItem(titleLabel)
                flex.addItem(subtitleLabel).marginTop(2)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlex.pin.all()
        rootFlex.flex.layout(mode: .adjustHeight)
    }
    
    func setSelected(_ isSelected: Bool, animated: Bool = true) {
        let borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.lightGray.withAlphaComponent(0.4).cgColor
        let bgColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.05) : .white
        
        guard animated else {
            layer.borderColor = borderColor
            backgroundColor = bgColor
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.layer.borderColor = borderColor
            self.backgroundColor = bgColor
        }
    }
}
