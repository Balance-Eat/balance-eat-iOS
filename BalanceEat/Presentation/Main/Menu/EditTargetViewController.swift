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
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let weightEditTargetItemView = EditTargetItemView(editTargetItemType: .weight)
    private let smiEditTargetItemView = EditTargetItemView(editTargetItemType: .smi)
    private let fatPercentageEditTargetItemView = EditTargetItemView(editTargetItemType: .fatPercentage)
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
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
        
        scrollView.addSubview(mainStackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        if let currentWeightValue = viewModel.userResponseRelay.value?.weight {
            weightEditTargetItemView.setCurrentText(String(currentWeightValue))
        }
        if let targetWeightValue = viewModel.userResponseRelay.value?.targetWeight {
            weightEditTargetItemView.setTargetText(String(targetWeightValue))
        }

        if let currentSmiValue = viewModel.userResponseRelay.value?.smi {
            smiEditTargetItemView.setCurrentText(String(currentSmiValue))
        }
        if let targetSmiValue = viewModel.userResponseRelay.value?.targetSmi {
            smiEditTargetItemView.setTargetText(String(targetSmiValue))
        }

        if let currentFatPercentageValue = viewModel.userResponseRelay.value?.fatPercentage {
            fatPercentageEditTargetItemView.setCurrentText(String(currentFatPercentageValue))
        }
        if let targetFatPercentageValue = viewModel.userResponseRelay.value?.targetFatPercentage {
            fatPercentageEditTargetItemView.setTargetText(String(targetFatPercentageValue))
        }

        
        [weightEditTargetItemView, smiEditTargetItemView, fatPercentageEditTargetItemView].forEach {
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
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true) // present 방식으로 열렸을 때
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
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
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
                diffLabel.text = String(format: "%.1f%@ %@", diff, self.editTargetItemType.unit, diff > 0 ? "증가" : "감소")
                diffLabel.textColor = diff > 0 ? .systemBlue : (diff < 0 ? .systemRed : .systemGray)
                diffLabel.backgroundColor = diff > 0 ? UIColor.systemBlue.withAlphaComponent(0.1) :
                (diff < 0 ? UIColor.systemRed.withAlphaComponent(0.1) : UIColor.clear)
            } else {
                diffLabel.text = ""
                diffLabel.textColor = .systemGray
                diffLabel.backgroundColor = .clear
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
