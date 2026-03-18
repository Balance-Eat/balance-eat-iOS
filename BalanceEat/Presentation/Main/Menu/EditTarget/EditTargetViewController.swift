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
            .map { Double($0 ?? "") }
            .bind(to: currentWeightRelay)
            .disposed(by: disposeBag)

        weightEditTargetItemView.targetText
            .map { Double($0 ?? "") }
            .bind(to: targetWeightRelay)
            .disposed(by: disposeBag)

        smiEditTargetItemView.currentText
            .map { Double($0 ?? "") }
            .bind(to: currentSMIRelay)
            .disposed(by: disposeBag)

        smiEditTargetItemView.targetText
            .map { Double($0 ?? "") }
            .bind(to: targetSMIRelay)
            .disposed(by: disposeBag)

        fatPercentageEditTargetItemView.currentText
            .map { Double($0 ?? "") }
            .bind(to: currentFatPercentageRelay)
            .disposed(by: disposeBag)

        fatPercentageEditTargetItemView.targetText
            .map { Double($0 ?? "") }
            .bind(to: targetFatPercentageRelay)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                let currentUser = userData

                let userDTO = UserDTO(
                    id: currentUser.id,
                    uuid: currentUser.uuid,
                    name: currentUser.name,
                    gender: currentUser.gender,
                    age: currentUser.age,
                    height: currentUser.height,
                    weight: currentWeightRelay.value ?? 0,
                    goalType: currentUser.goalType,
                    email: currentUser.email,
                    activityLevel: currentUser.activityLevel,
                    smi: currentSMIRelay.value,
                    fatPercentage: currentFatPercentageRelay.value,
                    targetWeight: targetWeightRelay.value ?? 0,
                    targetCalorie: currentUser.targetCalorie,
                    targetSmi: targetSMIRelay.value,
                    targetFatPercentage: targetFatPercentageRelay.value,
                    targetCarbohydrates: carbonRelay.value,
                    targetProtein: proteinRelay.value,
                    targetFat: fatRelay.value,
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

        Observable.combineLatest(carbonRelay, proteinRelay, fatRelay) { [weak self] carbon, protein, fat -> Bool in
            guard let self else { return false }

            let isCarbonMaintained = carbon == round(userData.targetCarbohydrates ?? 0)
            let isProteinMaintained = protein == round(userData.targetProtein ?? 0)
            let isFatMaintained = fat == round(userData.targetFat ?? 0)

            return isCarbonMaintained && isProteinMaintained && isFatMaintained
        }
        .bind(to: nutritionValueChangedRelay)
        .disposed(by: disposeBag)

        Observable.combineLatest(
            currentWeightRelay, targetWeightRelay,
            currentSMIRelay, targetSMIRelay,
            currentFatPercentageRelay, targetFatPercentageRelay
        ) { [weak self] currentWeight, targetWeight, currentSMI, targetSMI, currentFatPercentage, targetFatPercentage -> Bool in
            guard let self else { return false }

            return currentWeight == userData.weight
                && targetWeight == userData.targetWeight
                && currentSMI == userData.smi
                && targetSMI == userData.targetSmi
                && currentFatPercentage == userData.fatPercentage
                && targetFatPercentage == userData.targetFatPercentage
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

        bottomConstraint?.update(inset: frame.height)
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
