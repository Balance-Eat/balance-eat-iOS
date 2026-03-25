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

    private var updateUserTask: Task<Void, Never>?

    override init(viewModel: EditTargetViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        updateUserTask?.cancel()
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

        let userData = viewModel.userData

        weightEditTargetItemView.setCurrentText(userData.weight.displayString)
        weightEditTargetItemView.setTargetText(userData.targetWeight.displayString)
        smiEditTargetItemView.setCurrentText(userData.smi.displayString)
        smiEditTargetItemView.setTargetText(userData.targetSmi.displayString)
        fatPercentageEditTargetItemView.setCurrentText(userData.fatPercentage.displayString)
        fatPercentageEditTargetItemView.setTargetText(userData.targetFatPercentage.displayString)

        let goalSummaryView = GoalSummaryView(
            currentWeightRelay: viewModel.currentWeightRelay,
            targetWeightRelay: viewModel.targetWeightRelay,
            currentSMIRelay: viewModel.currentSMIRelay,
            targetSMIRelay: viewModel.targetSMIRelay,
            currentFatPercentageRelay: viewModel.currentFatPercentageRelay,
            targetFatPercentageRelay: viewModel.targetFatPercentageRelay
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
            .bind(to: viewModel.currentWeightRelay)
            .disposed(by: disposeBag)

        weightEditTargetItemView.targetText
            .map { Double($0 ?? "") }
            .bind(to: viewModel.targetWeightRelay)
            .disposed(by: disposeBag)

        smiEditTargetItemView.currentText
            .map { Double($0 ?? "") }
            .bind(to: viewModel.currentSMIRelay)
            .disposed(by: disposeBag)

        smiEditTargetItemView.targetText
            .map { Double($0 ?? "") }
            .bind(to: viewModel.targetSMIRelay)
            .disposed(by: disposeBag)

        fatPercentageEditTargetItemView.currentText
            .map { Double($0 ?? "") }
            .bind(to: viewModel.currentFatPercentageRelay)
            .disposed(by: disposeBag)

        fatPercentageEditTargetItemView.targetText
            .map { Double($0 ?? "") }
            .bind(to: viewModel.targetFatPercentageRelay)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.updateUserTask = Task {
                    await self.viewModel.updateUser()
                }
            })
            .disposed(by: disposeBag)

        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                let userData = viewModel.userData

                weightEditTargetItemView.setCurrentText(userData.weight.displayString)
                weightEditTargetItemView.setTargetText(userData.targetWeight.displayString)
                smiEditTargetItemView.setCurrentText(userData.smi.displayString)
                smiEditTargetItemView.setTargetText(userData.targetSmi.displayString)
                fatPercentageEditTargetItemView.setCurrentText(userData.fatPercentage.displayString)
                fatPercentageEditTargetItemView.setTargetText(userData.targetFatPercentage.displayString)
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

        viewModel.isUnchangedObservable
            .map { !$0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.isUnchangedObservable
            .bind(to: menuEditedWarningView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.isUnchangedObservable
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
