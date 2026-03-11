//
//  EditTargetTypeAndActivityLevelViewController.swift
//  BalanceEat
//
//  Created by 김견 on 10/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditTargetTypeAndActivityLevelViewController: BaseViewController<EditTargetTypeAndActivityLevelViewModel> {
    private let goalPickerView = GoalPickerView()
    
    private let activityLevelPickerView = ActivityLevelPickerView()
    private let estimatedDailyCalorieView = EstimatedDailyCalorieView(title: "예상 일일 소모 칼로리")
    
    private let goToNutritionSettingButton = GoToNutritionSettingButton()
    
    private let resetButton = MenuResetButton()
    
    private let menuEditedWarningView = MenuEditedWarningView()
    
    
    private let valueChangedRelay = BehaviorRelay<Bool>(value: false)
    
    private var bottomConstraint: Constraint?
    
    var onGoToNutritionSetting: (() -> Void)?

    override init(viewModel: EditTargetTypeAndActivityLevelViewModel) {
        super.init(viewModel: viewModel)
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
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
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints { make in
            self.bottomConstraint = make.bottom.equalToSuperview().inset(0).constraint
        }
        
        let goalPickViewContentView = EditDataContentView(
            systemImageString: "dot.scope",
            imageBackgroundColor: .blue,
            titleText: "목표 유형",
            subtitleText: "원하는 신체 변화를 선택하세요.",
            subView: goalPickerView
        )
        goalPickerView.setSelectedType(type: viewModel.userRelay.value?.goalType ?? .none)
        
        let activityLevelPickerViewContentView = EditDataContentView(
            systemImageString: "heart.fill",
            imageBackgroundColor: .red,
            titleText: "활동량",
            subtitleText: "일상적인 활동 수준을 선택하세요.",
            subView: activityLevelPickerView
        )
        activityLevelPickerView.setSelectedLevel(activityLevel: viewModel.userRelay.value?.activityLevel ?? .sedentary)
        
        let menuTipView = MenuTipView(
            title: "설정 가이드",
            menuTips: [
                MenuTipData(
                    title: "🎯 목표 유형",
                    description: """
                    체중을 줄이고 싶다면 다이어트, 근육을 키우고 싶다면 벌크업을 선택하세요.
                    """
                ),
                MenuTipData(
                    title: "🔥 활동량",
                    description: """
                    일주일 평균 운동 빈도를 기준으로 선택하세요. 과대평가보다는 보수적으로 선택하는 것을 추천합니다.
                    """
                ),
                MenuTipData(
                    title: "🥗 칼로리 조정",
                    description: """
                    설정 변경 시 일일 목표 칼로리가 자동으로 재계산됩니다.
                    """
                )
            ]
        )
        
        goToNutritionSettingButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
                
        [goalPickViewContentView, activityLevelPickerViewContentView, estimatedDailyCalorieView, goToNutritionSettingButton, resetButton, menuEditedWarningView, menuTipView].forEach(mainStackView.addArrangedSubview(_:))
        
        navigationItem.title = "목표, 활동량 설정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setBinding() {
        goalPickerView.selectedGoalRelay
            .subscribe(onNext: { [weak self] goal in
                guard let self else { return }
                viewModel.selectedGoalRelay.accept(goal)
            })
            .disposed(by: disposeBag)
        
        activityLevelPickerView.selectedActivityLevelRelay
            .subscribe(onNext: { [weak self] level in
                guard let self else { return }
                viewModel.selectedActivityLevel.accept(level)
                estimatedDailyCalorieView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        viewModel.targetCaloriesObservable
            .bind(to: estimatedDailyCalorieView.calorieRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.selectedGoalRelay, viewModel.selectedActivityLevel, viewModel.userRelay)
        { goal, level, user in
            let isGoalMaintained = goal == user?.goalType
            let isActivityLevelMaintained = level == user?.activityLevel

            return isGoalMaintained && isActivityLevelMaintained
        }
        .bind(to: valueChangedRelay)
        .disposed(by: disposeBag)
        
//        valueChangedRelay
//            .map { !$0 }
//            .bind(to: goToNutritionSettingButton.rx.isEnabled)
//            .disposed(by: disposeBag)
        
        valueChangedRelay
            .bind(to: menuEditedWarningView.rx.isHidden)
            .disposed(by: disposeBag)
        
        valueChangedRelay
            .bind(to: resetButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        goToNutritionSettingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onGoToNutritionSetting?()
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                guard let userData = viewModel.userRelay.value else { return }
                
                goalPickerView.setSelectedType(type: userData.goalType)
                activityLevelPickerView.setSelectedLevel(activityLevel: userData.activityLevel)
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
