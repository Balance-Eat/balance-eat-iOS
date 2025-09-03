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
    
    private let currentWeightRelay = PublishRelay<String?>()
    private let targetWeightRelay = PublishRelay<String?>()
    private let currentSMIRelay = PublishRelay<String?>()
    private let targetSMIRelay = PublishRelay<String?>()
    private let currentFatPercentageRelay = PublishRelay<String?>()
    private let targetFatPercentageRelay = PublishRelay<String?>()
    
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
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
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
        }

        if let targetWeightValue = viewModel.userResponseRelay.value?.targetWeight {
            let text = targetWeightValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetWeightValue))
                : String(targetWeightValue)
            weightEditTargetItemView.setTargetText(text)
        }

        if let currentSmiValue = viewModel.userResponseRelay.value?.smi {
            let text = currentSmiValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentSmiValue))
                : String(currentSmiValue)
            smiEditTargetItemView.setCurrentText(text)
        }

        if let targetSmiValue = viewModel.userResponseRelay.value?.targetSmi {
            let text = targetSmiValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(targetSmiValue))
                : String(targetSmiValue)
            smiEditTargetItemView.setTargetText(text)
        }

        if let currentFatPercentageValue = viewModel.userResponseRelay.value?.fatPercentage {
            let text = currentFatPercentageValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(currentFatPercentageValue))
                : String(currentFatPercentageValue)
            fatPercentageEditTargetItemView.setCurrentText(text)
        }

        if let targetFatPercentageValue = viewModel.userResponseRelay.value?.targetFatPercentage {
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
        
        [weightEditTargetItemView, smiEditTargetItemView, fatPercentageEditTargetItemView, goalSummaryView].forEach {
            mainStackView.addArrangedSubview($0)
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
    
    private let currentWeightRelay: PublishRelay<String?>
    private let targetWeightRelay: PublishRelay<String?>
    private let currentSMIRelay: PublishRelay<String?>
    private let targetSMIRelay: PublishRelay<String?>
    private let currentFatPercentageRelay: PublishRelay<String?>
    private let targetFatPercentageRelay: PublishRelay<String?>
    
    init(currentWeightRelay: PublishRelay<String?>, targetWeightRelay: PublishRelay<String?>, currentSMIRelay: PublishRelay<String?>, targetSMIRelay: PublishRelay<String?>, currentFatPercentageRelay: PublishRelay<String?>, targetFatPercentageRelay: PublishRelay<String?>) {
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
    
    init(editTargetItemType: EditTargetItemType, currentRelay: PublishRelay<String?>, targetRelay: PublishRelay<String?>) {
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
