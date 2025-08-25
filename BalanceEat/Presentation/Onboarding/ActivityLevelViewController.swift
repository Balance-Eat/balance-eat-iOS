//
//  ActivityLevelViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FlexLayout
import PinLayout

class ActivityLevelViewController: UIViewController {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "활동량을 선택해주세요."
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "일상적인 활동 수준에 따라 맞춤 칼로리를 계산합니다."
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    private let estimatedDailyCalorieView = EstimatedDailyCalorieView()
    
    private var selectedActivityLevel: BehaviorRelay<ActivityLevel> = BehaviorRelay(value: .none)
    let inputCompleted = PublishRelay<Void>()
    
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
        view.backgroundColor = .homeScreenBackground
        
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
        
        let activityLevelPickerView = ActivityLevelPickerView()
        activityLevelPickerView.selectedActivityLevelRelay
            .subscribe(onNext: { [weak self] level in
                guard let self = self else { return }
                self.selectedActivityLevel.accept(level)
                self.estimatedDailyCalorieView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        estimatedDailyCalorieView.isHidden = true
        
        
        
        
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
        
        [activityLevelPickerView, estimatedDailyCalorieView, nextButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
    }
    
    private func setUpBinding() {
        TutorialPageViewModel.shared.targetCaloriesObservable
            .bind(to: self.estimatedDailyCalorieView.calorieRelay)
            .disposed(by: disposeBag)
        
        selectedActivityLevel
            .subscribe(onNext: { [weak self] level in
                guard let self = self else { return }
                var data = TutorialPageViewModel.shared.dataRelay.value
                data.activityLevel = level
                TutorialPageViewModel.shared.dataRelay.accept(data)
                
                self.estimatedDailyCalorieView.isHidden = false
                
                TutorialPageViewModel.shared.targetCaloriesObservable
                    .bind(to: self.estimatedDailyCalorieView.calorieRelay)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}

final class ActivityLevelPickerView: UIView {
    let selectedActivityLevelRelay = PublishRelay<ActivityLevel>()
    
    private let rootFlex = UIView()
    
    private let sedentaryCard = ActivityLevelCardView(activityLevel: .sedentary)
    private let lightlyActiveCard = ActivityLevelCardView(activityLevel: .light)
    private let moderatelyActiveCard = ActivityLevelCardView(activityLevel: .moderate)
    private let vigorouslyActiveCard = ActivityLevelCardView(activityLevel: .active)
    
    private var selectedLevel: ActivityLevel? {
        didSet {
            updateSelection(animated: true)
            if let selectedLevel = selectedLevel {
                selectedActivityLevelRelay.accept(selectedLevel)
            }
        }
    }
    
    private let cardHeight: CGFloat = 100
    private let gap: CGFloat = 12
    private let cardCount: CGFloat = 4
    
    override var intrinsicContentSize: CGSize {
        let height = cardHeight * cardCount + gap * (cardCount - 1)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
        setUpActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpLayout() {
        addSubview(rootFlex)
        
        rootFlex.flex.direction(.column).gap(gap)
            .define { flex in
                flex.addItem(sedentaryCard).height(cardHeight)
                flex.addItem(lightlyActiveCard)
                    .height(cardHeight)
                flex.addItem(moderatelyActiveCard)
                    .height(cardHeight)
                flex.addItem(vigorouslyActiveCard)
                    .height(cardHeight)
            }
    }
    
    private func setUpActions() {
        [sedentaryCard, lightlyActiveCard, moderatelyActiveCard, vigorouslyActiveCard].forEach { card in
            card.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            card.addGestureRecognizer(tap)
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else {
            return
        }
        if tappedView === sedentaryCard {
            selectedLevel = .sedentary
        } else if tappedView === lightlyActiveCard {
            selectedLevel = .light
        } else if tappedView === moderatelyActiveCard {
            selectedLevel = .moderate
        } else if tappedView === vigorouslyActiveCard {
            selectedLevel = .active
        }
    }
    
    private func updateSelection(animated: Bool) {
        sedentaryCard.setSelected(selectedLevel == .sedentary, animated: animated)
        lightlyActiveCard.setSelected(selectedLevel == .light, animated: animated)
        moderatelyActiveCard.setSelected(selectedLevel == .moderate, animated: animated)
        vigorouslyActiveCard.setSelected(selectedLevel == .active, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlex.pin.all()
        rootFlex.flex.layout(mode: .adjustHeight)
    }
}

final class ActivityLevelCardView: UIView {
    private let activityLevel: ActivityLevel
    
    private let rootFlex = UIView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    init(activityLevel: ActivityLevel) {
        self.activityLevel = activityLevel
        
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        
        emojiLabel.text = activityLevel.emoji
        emojiLabel.font = .systemFont(ofSize: 28)
        
        titleLabel.text = activityLevel.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        subtitleLabel.text = activityLevel.subtitle
        subtitleLabel.font = .systemFont(ofSize: 14)
        
        descriptionLabel.text = activityLevel.description
        descriptionLabel.font = .systemFont(ofSize: 12)
        descriptionLabel.textColor = .gray
        
        addSubview(rootFlex)
        
        rootFlex.flex.direction(.row).padding(16).define { flex in
            flex.addItem(emojiLabel)
                .marginRight(16)
            
            flex.addItem().direction(.column).grow(1).shrink(1).define { flex in
                flex.addItem(titleLabel).marginBottom(8)
                flex.addItem(subtitleLabel)
                flex.addItem(descriptionLabel).marginTop(8)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlex.pin.all()
        rootFlex.flex.layout(mode: .adjustHeight)
    }
    
    func setSelected(_ isSelected: Bool, animated: Bool = true) {
        let borderColor = isSelected ? activityLevel.selectedBorderColor.cgColor : UIColor.lightGray.withAlphaComponent(0.4).cgColor
        let borderWidth: CGFloat = isSelected ? 2 : 1
        
        let bgColor = isSelected ? activityLevel.selectedBorderColor.withAlphaComponent(0.1) : .white
        
        guard animated else {
            layer.borderColor = borderColor
            layer.borderWidth = borderWidth
            backgroundColor = bgColor
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.layer.borderColor = borderColor
            self.layer.borderWidth = borderWidth
            self.backgroundColor = bgColor
        }
    }
}
