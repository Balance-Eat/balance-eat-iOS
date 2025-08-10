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
    
    let inputCompleted = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    private var selectedGoal: GoalType?

    
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
        
        let currentWeightView = self.currentWeightView(weight: "70.0")
        
        let weightInputField = InputFieldWithIcon(icon: UIImage(systemName: "scalemass")!, placeholder: "목표 체중을 입력해주세요.", unit: "kg")
        let weightInputView = TitledInputUserInfoView(title: "목표 체중", inputView: weightInputField)
        
        let goalPickerView = GoalPickerView()
        goalPickerView.selectedGoalRelay
            .subscribe(onNext: { [weak self] goal in
                guard let self = self else { return }
                self.selectedGoal = goal
            })
            .disposed(by: disposeBag)
        let goalPickerInputView = TitledInputUserInfoView(title: "목표 유형", inputView: goalPickerView)
        
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
            .subscribe(onNext: { [weak self] in
                self?.inputCompleted.accept(())
            })
            .disposed(by: disposeBag)
        
        [currentWeightView, weightInputView, goalPickerInputView, nextButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
    }
    
    private func currentWeightView(weight: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.text = "현재 체중 : "
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        
        let weightLabel = UILabel()
        weightLabel.text = "\(weight)kg"
        weightLabel.font = .systemFont(ofSize: 18, weight: .bold)
        weightLabel.textColor = .black
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, weightLabel])
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
    }
}

enum GoalType {
    case diet
    case bulkUp
    case maintain
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
            card.isUserInteractionEnabled = true // 혹시 모르니 명시
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
