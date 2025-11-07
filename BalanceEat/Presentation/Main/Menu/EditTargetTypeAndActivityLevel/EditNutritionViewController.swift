//
//  EditNutritionViewController.swift
//  BalanceEat
//
//  Created by 김견 on 11/3/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditNutritionViewController: BaseViewController<EditTargetTypeAndActivityLevelViewModel> {
    private let editNutritionInfoView = EditNutritionInfoView()
    
    private let saveButton = MenuSaveButton()
    
    private let resetButton = ResetToRecommendValueButton()
    
    private var initialCarbon: Double = 0
    private var initialProtein: Double = 0
    private var initialFat: Double = 0
    
    private var bottomConstraint: Constraint?
    
    init(vm: EditTargetTypeAndActivityLevelViewModel) {
        super.init(viewModel: vm)
        
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
        
        let nutritionEditTargetContentView = EditDataContentView(
            systemImageString: "chart.bar.fill",
            imageBackgroundColor: .orange,
            titleText: "탄단지",
            subtitleText: "목표와 활동량을 통한 권장 탄단지입니다. (수정 가능)",
            subView: editNutritionInfoView
        )
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        [nutritionEditTargetContentView, saveButton, resetButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        navigationItem.title = "섭취 목표 설정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func setBinding() {
        Observable.combineLatest(viewModel.targetCaloriesRelay, viewModel.selectedGoalRelay, viewModel.userRelay)
            .subscribe(onNext: { [weak self] calories, goal, data in
                guard let self = self else { return }
                
                var carbon: Double = 0
                var protein: Double = 0
                var fat: Double = 0
                
                switch goal {
                case .diet:
                    protein = (data?.weight ?? 0) * 2
                    fat = calories * 0.2 / 9
                    carbon = (calories - protein * 4 - fat * 9) / 4
                case .bulkUp:
                    protein = (data?.weight ?? 0) * 2
                    fat = calories * 0.2 / 9
                    carbon = (calories - protein * 4 - fat * 9) / 4
                case .maintain:
                    protein = (data?.weight ?? 0) * 1.7
                    fat = calories * 0.2
                    carbon = (calories - protein * 4 - fat * 9) / 4
                case .none:
                    break
                }
                
                initialCarbon = carbon
                initialProtein = protein
                initialFat = fat
                
                editNutritionInfoView.setCarbonText(text: String(format: "%.0f", carbon))
                editNutritionInfoView.setProteinText(text: String(format: "%.0f", protein))
                editNutritionInfoView.setFatText(text: String(format: "%.0f", fat))
            })
            .disposed(by: disposeBag)
        
        editNutritionInfoView.carbonRelay
            .bind(to: viewModel.userCarbonRelay)
            .disposed(by: disposeBag)
        
        editNutritionInfoView.proteinRelay
            .bind(to: viewModel.userProteinRelay)
            .disposed(by: disposeBag)
        
        editNutritionInfoView.fatRelay
            .bind(to: viewModel.userFatRelay)
            .disposed(by: disposeBag)
        
//        viewModel.userCarbonRelay
//            .subscribe(onNext: { [weak self] carbon in
//                guard let self else { return }
//                editNutritionInfoView.setCarbonText(text: String(format: "%.0f", carbon))
//            })
//            .disposed(by: disposeBag)
//        
//        viewModel.userProteinRelay
//            .subscribe(onNext: { [weak self] protein in
//                guard let self else { return }
//                editNutritionInfoView.setProteinText(text: String(format: "%.0f", protein))
//            })
//            .disposed(by: disposeBag)
//        
//        viewModel.userFatRelay
//            .subscribe(onNext: { [weak self] fat in
//                guard let self else { return }
//                editNutritionInfoView.setFatText(text: String(format: "%.0f", fat))
//            })
//            .disposed(by: disposeBag)
        
        viewModel.updateUserResultRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] updateUserResult in
                guard let self else { return }
                if updateUserResult {
                    navigationController?.popToRootViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                guard let userData = viewModel.userRelay.value else {
                    return
                }
                
                let goal = viewModel.selectedGoalRelay.value
                let activityLevel = viewModel.selectedActivityLevel.value
                let targetCarbonCal = viewModel.userCarbonRelay.value * 4
                let targetProteinCal = viewModel.userProteinRelay.value * 4
                let targetFatCal = viewModel.userFatRelay.value * 9
                let targetCalorie = targetCarbonCal + targetProteinCal + targetFatCal
                
                let userDTO = UserDTO(
                    id: userData.id ,
                    uuid: userData.uuid,
                    name: userData.name,
                    gender: userData.gender,
                    age: userData.age,
                    height: userData.height,
                    weight: userData.weight,
                    goalType: goal,
                    email: userData.email,
                    activityLevel: activityLevel,
                    smi: userData.smi,
                    fatPercentage: userData.fatPercentage,
                    targetWeight: userData.targetWeight,
                    targetCalorie: targetCalorie,
                    targetSmi: userData.targetSmi,
                    targetFatPercentage: userData.targetFatPercentage,
                    targetCarbohydrates: viewModel.userCarbonRelay.value,
                    targetProtein: viewModel.userProteinRelay.value,
                    targetFat: viewModel.userFatRelay.value,
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
                editNutritionInfoView.setCarbonText(text: String(format: "%.0f", initialCarbon))
                editNutritionInfoView.setProteinText(text: String(format: "%.0f", initialProtein))
                editNutritionInfoView.setFatText(text: String(format: "%.0f", initialFat))
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
