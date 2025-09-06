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

class EditTargetViewController: UIViewController {
    private let viewModel: MenuViewModel
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let weightEditTargetItemView = EditTargetItemView(editTargetItemType: .weight)
    private let smiEditTargetItemView = EditTargetItemView(editTargetItemType: .smi)
    private let fatPercentageEditTargetItemView = EditTargetItemView(editTargetItemType: .fatPercentage)
    
    private let saveButton = TitledButton(
        title: "변경사항 저장",
        image: UIImage(systemName: "square.and.arrow.down"),
        style: .init(
            backgroundColor: .systemBlue,
            titleColor: .white,
            borderColor: nil
        )
    )
    
    private let resetButton = TitledButton(
        title: "원래 값으로 되돌리기",
        image: UIImage(systemName: "arrow.clockwise"),
        style: .init(
            backgroundColor: .white,
            titleColor: .black,
            borderColor: .lightGray
        )
    )
    
    private let warningContainerView: UIView = {
        let uiView = UIView()
        uiView.isHidden = true
        return uiView
    }()
    
    private let showTargetGuideButton = TargetGuideButton()
    
    private let currentWeightRelay = BehaviorRelay<String?>(value: nil)
    private let targetWeightRelay = BehaviorRelay<String?>(value: nil)
    private let currentSMIRelay = BehaviorRelay<String?>(value: nil)
    private let targetSMIRelay = BehaviorRelay<String?>(value: nil)
    private let currentFatPercentageRelay = BehaviorRelay<String?>(value: nil)
    private let targetFatPercentageRelay = BehaviorRelay<String?>(value: nil)
    
    private var originCurrentWeight: String?
    private var originTargetWeight: String?
    private var originCurrentSMI: String?
    private var originTargetSMI: String?
    private var originCurrentFatPercentage: String?
    private var originTargetFatPercentage: String?
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setUpView() {
        
        view.backgroundColor = .homeScreenBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        if let currentWeightValue = viewModel.userResponseRelay.value?.weight {
            let text = currentWeightValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentWeightValue))
                : String(currentWeightValue)
            weightEditTargetItemView.setCurrentText(text)
            self.originCurrentWeight = text
        }

        if let targetWeightValue = viewModel.userResponseRelay.value?.targetWeight {
            let text = targetWeightValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetWeightValue))
                : String(targetWeightValue)
            weightEditTargetItemView.setTargetText(text)
            self.originTargetWeight = text
        }

        if let currentSmiValue = viewModel.userResponseRelay.value?.smi {
            let text = currentSmiValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentSmiValue))
                : String(currentSmiValue)
            smiEditTargetItemView.setCurrentText(text)
            self.originCurrentSMI = text
        }

        if let targetSmiValue = viewModel.userResponseRelay.value?.targetSmi {
            let text = targetSmiValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetSmiValue))
                : String(targetSmiValue)
            smiEditTargetItemView.setTargetText(text)
            self.originTargetSMI = text
        }

        if let currentFatPercentageValue = viewModel.userResponseRelay.value?.fatPercentage {
            let text = currentFatPercentageValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentFatPercentageValue))
                : String(currentFatPercentageValue)
            fatPercentageEditTargetItemView.setCurrentText(text)
            self.originCurrentFatPercentage = text
        }

        if let targetFatPercentageValue = viewModel.userResponseRelay.value?.targetFatPercentage {
            let text = targetFatPercentageValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetFatPercentageValue))
                : String(targetFatPercentageValue)
            fatPercentageEditTargetItemView.setTargetText(text)
            self.originTargetFatPercentage = text
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
        
        let warningImageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        warningImageView.tintColor = .systemRed
        
        warningImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
        }
        
        let warningLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 13, weight: .regular)
            label.textColor = .systemRed
            label.numberOfLines = 0
            label.text = "변경사항이 있습니다. 저장하시겠습니까?"
            return label
        }()
        
        let warningStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [warningImageView, warningLabel])
            stackView.axis = .horizontal
            stackView.spacing = 8
            return stackView
        }()
        
        warningContainerView.addSubview(warningStackView)
        
        warningStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
        }
        
        let measurementTipsView = MeasurementTipsView()
        
        [showTargetGuideButton, weightEditTargetItemView, smiEditTargetItemView, fatPercentageEditTargetItemView, goalSummaryView, saveButton, resetButton, warningContainerView, measurementTipsView].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        warningContainerView.snp.makeConstraints { make in
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
            .bind(to: currentWeightRelay)
            .disposed(by: disposeBag)
        
        weightEditTargetItemView.targetText
            .bind(to: targetWeightRelay)
            .disposed(by: disposeBag)
        
        smiEditTargetItemView.currentText
            .bind(to: currentSMIRelay)
            .disposed(by: disposeBag)
        
        smiEditTargetItemView.targetText
            .bind(to: targetSMIRelay)
            .disposed(by: disposeBag)
        
        fatPercentageEditTargetItemView.currentText
            .bind(to: currentFatPercentageRelay)
            .disposed(by: disposeBag)
        
        fatPercentageEditTargetItemView.targetText
            .bind(to: targetFatPercentageRelay)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                if let originCurrentWeight = self.originCurrentWeight {
                    self.weightEditTargetItemView.setCurrentText(originCurrentWeight)
                }
                if let originTargetWeight = self.originTargetWeight {
                    self.weightEditTargetItemView.setTargetText(originTargetWeight)
                }
                
                if let originCurrentSMI = self.originCurrentSMI {
                    self.smiEditTargetItemView.setCurrentText(originCurrentSMI)
                }
                if let originTargetSMI = self.originTargetSMI {
                    self.smiEditTargetItemView.setTargetText(originTargetSMI)
                }
                
                if let originCurrentFatPercentage = self.originCurrentFatPercentage {
                    self.fatPercentageEditTargetItemView.setCurrentText(originCurrentFatPercentage)
                }
                if let originTargetFatPercentage = self.originTargetFatPercentage {
                    self.fatPercentageEditTargetItemView.setTargetText(originTargetFatPercentage)
                }
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
            currentWeightRelay,
            targetWeightRelay,
            currentSMIRelay,
            targetSMIRelay,
            currentFatPercentageRelay,
            targetFatPercentageRelay
        ) { [weak self] currentWeight, targetWeight, currentSMI, targetSMI, currentFatPercentage, targetFatPercentage -> Bool in
            
            guard let self else { return false }
            
            let isCurrentWeightMaintained = currentWeight == originCurrentWeight
            let isTargetWeightMaintained = targetWeight == originTargetWeight
            let isCurrentSMIMaintained = currentSMI == originCurrentSMI
            let isTargetSMIMaintained = targetSMI == originTargetSMI
            let isCurrentFatPercentageMaintained = currentFatPercentage == originCurrentFatPercentage
            let isTargetFatPercentageMaintained = targetFatPercentage == originTargetFatPercentage
            
            return isCurrentWeightMaintained && isTargetWeightMaintained && isCurrentSMIMaintained && isTargetSMIMaintained && isCurrentFatPercentageMaintained && isTargetFatPercentageMaintained
        }
        .bind(to: warningContainerView.rx.isHidden)
        .disposed(by: disposeBag)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
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

final class EditTargetItemView: BalanceEatContentView {
    private let editTargetItemType: EditTargetItemType
    
    private let currentField = InputFieldWithIcon(placeholder: "", unit: "kg")
    private let targetField = InputFieldWithIcon(placeholder: "", unit: "kg")
    
    private let titleIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage())
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    private let imageBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    var currentText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var targetText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()
    
    init(editTargetItemType: EditTargetItemType) {
        self.editTargetItemType = editTargetItemType
    
        super.init()
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
        titleIconImageView.image = UIImage(systemName: editTargetItemType.systemImage)
        
        imageBackgroundView.backgroundColor = editTargetItemType.color
        imageBackgroundView.clipsToBounds = true
        imageBackgroundView.addSubview(titleIconImageView)
        
        titleIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.edges.equalToSuperview().inset(10)
        }
        
        titleLabel.text = editTargetItemType.title
        
        subtitleLabel.text = editTargetItemType.subtitle
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        
        let titleStackView = UIStackView(arrangedSubviews: [imageBackgroundView, labelStackView])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 12
        
        
        mainStackView.addArrangedSubview(titleStackView)
        
        
        let currentTitledInputUserInfoView = TitledInputUserInfoView(title: "현재 \(editTargetItemType.title)", inputView: currentField, useBalanceEatWrapper: false)
        
        currentField.textObservable
            .bind(to: currentText)
            .disposed(by: disposeBag)
        
        let targetTitledInputUserInfoView = TitledInputUserInfoView(title: "목표 \(editTargetItemType.title)", inputView: targetField, useBalanceEatWrapper: false)
        
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
            guard let self = self else { return }
            
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
            make.edges.equalToSuperview().inset(16)
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
    
    private let currentWeightRelay: BehaviorRelay<String?>
    private let targetWeightRelay: BehaviorRelay<String?>
    private let currentSMIRelay: BehaviorRelay<String?>
    private let targetSMIRelay: BehaviorRelay<String?>
    private let currentFatPercentageRelay: BehaviorRelay<String?>
    private let targetFatPercentageRelay: BehaviorRelay<String?>
    
    init(currentWeightRelay: BehaviorRelay<String?>, targetWeightRelay: BehaviorRelay<String?>, currentSMIRelay: BehaviorRelay<String?>, targetSMIRelay: BehaviorRelay<String?>, currentFatPercentageRelay: BehaviorRelay<String?>, targetFatPercentageRelay: BehaviorRelay<String?>) {
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
    
    init(editTargetItemType: EditTargetItemType, currentRelay: BehaviorRelay<String?>, targetRelay: BehaviorRelay<String?>) {
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        
        iconImageView.image = UIImage(systemName: editTargetItemType.systemImage)
        iconImageView.tintColor = editTargetItemType.color
        titleLabel.text = editTargetItemType.title
        
        Observable.combineLatest(currentRelay, targetRelay)
            .subscribe(onNext: { [weak self] current, target in
                guard let self else { return }

                let currentValue = Double(current ?? "0") ?? 0
                let targetValue = Double(target ?? "0") ?? 0
                let diff = targetValue - currentValue

                self.changeLabel.text = "\(currentValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", currentValue) : String(currentValue))\(editTargetItemType.unit) → \(targetValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", targetValue) : String(targetValue))\(editTargetItemType.unit)"


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

final class MeasurementTipsView: UIView {
    
    private let contentView = BalanceEatContentView()
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "info.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "측정 및 업데이트 팁"
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let measurementSectionView = UIView()
    private let measurementTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📅 측정 주기:"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    private let measurementBodyLabel: UILabel = {
        let label = UILabel()
        label.text = """
        • 체중: 매일 (같은 시간)
        • 골격근량: 월 1-2회
        • 체지방률: 월 1-2회
        """
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let goalSectionView = UIView()
    private let goalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎯 목표 수정:"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    private let goalBodyLabel: UILabel = {
        let label = UILabel()
        label.text = """
        • 진행 상황에 맞춰 조정
        • 급격한 변화는 피하기
        • 전문가 상담 권장
        """
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(contentView)
        
        contentView.addSubview(titleStackView)
        
        contentView.addSubview(measurementSectionView)
        measurementSectionView.addSubview(measurementTitleLabel)
        measurementSectionView.addSubview(measurementBodyLabel)
        
        contentView.addSubview(goalSectionView)
        goalSectionView.addSubview(goalTitleLabel)
        goalSectionView.addSubview(goalBodyLabel)
    }
    
    private func setupConstraints() {
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(16)
        }
        
        measurementSectionView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        measurementTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        measurementBodyLabel.snp.makeConstraints { make in
            make.top.equalTo(measurementTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        goalSectionView.snp.makeConstraints { make in
            make.top.equalTo(measurementSectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        goalTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        goalBodyLabel.snp.makeConstraints { make in
            make.top.equalTo(goalTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
