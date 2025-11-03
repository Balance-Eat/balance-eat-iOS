//
//  MacroSettingViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MacroSettingViewController: UIViewController {
    private let viewModel = TutorialPageViewModel.shared
    private let disposeBag = DisposeBag()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "영양소 비율을 설정하세요."
        label.textColor = .black
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let resetButton = ResetToRecommendValueButton()
    
    private let targetCaloriesRelayForCarbonProtein: BehaviorRelay<CGFloat> = .init(value: 2000 / 4)
    private let targetCaloriesRelayForFat: BehaviorRelay<CGFloat> = .init(value: 2000 / 9)
    
    private var initialCarbon: Float = 0
    private var initialProtein: Float = 0
    private var initialFat: Float = 0
    
    let inputCompleted = PublishRelay<Void>()
    
    init () {
        super.init(nibName: nil, bundle: nil)
        setUpView()
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
        
        let carbonSlider = NutritionSettingSlider(
            title: "탄수화물",
            sliderThumbColor: .carbonText,
            sliderBackgroundColor: .carbonText.withAlphaComponent(0.1),
            maximumValueRelay: targetCaloriesRelayForCarbonProtein
        )
        
        let proteinSlider = NutritionSettingSlider(
            title: "단백질",
            sliderThumbColor: .proteinText,
            sliderBackgroundColor: .proteinText.withAlphaComponent(0.1),
            maximumValueRelay: targetCaloriesRelayForCarbonProtein
        )
        
        let fatSlider = NutritionSettingSlider(
            title: "지방",
            sliderThumbColor: .fatText,
            sliderBackgroundColor: .fatText.withAlphaComponent(0.1),
            maximumValueRelay: targetCaloriesRelayForFat
        )
        
        let estimatedDailyCalorieView = EstimatedDailyCalorieView(title: "하루 권장 섭취 칼로리")
        
        let nutritionGuideView = NutritionGuideView()
        
        let nextButton = TitledButton(
            title: "입력 완료",
            style: .init(
                backgroundColor: nil,
                titleColor: .white,
                borderColor: nil,
                gradientColors: [.systemGreen, .systemGreen.withAlphaComponent(0.5)]
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
        
        [carbonSlider, proteinSlider, fatSlider, estimatedDailyCalorieView, resetButton, nutritionGuideView, nextButton].forEach(mainStackView.addArrangedSubview)
        
        Observable.combineLatest(viewModel.targetCaloriesRelay, viewModel.goalTypeRelay, viewModel.dataRelay)
            .subscribe(onNext: { [weak self] calories, goal, data in
                guard let self = self else { return }
                
                var carbon: Float = 4
                var protein: Float = 4
                var fat: Float = 9
                
                switch goal {
                case .diet:
                    protein = protein * Float(data.weight ?? 0) * 2
                    fat = Float(calories) * 0.2
                    carbon = Float(calories) - protein - fat
                case .bulkUp:
                    protein = protein * Float(data.weight ?? 0) * 2
                    fat = Float(calories) * 0.2
                    carbon = Float(calories) - protein - fat
                case .maintain:
                    protein = protein * Float(data.weight ?? 0) * 1.7
                    fat = Float(calories) * 0.2
                    carbon = Float(calories) - protein - fat
                case .none:
                    break
                }
                
                self.initialCarbon = carbon
                self.initialProtein = protein
                self.initialFat = fat
                
                self.viewModel.userCarbonRelay.accept(carbon)
                self.viewModel.userProteinRelay.accept(protein)
                self.viewModel.userFatRelay.accept(fat)
            })
            .disposed(by: disposeBag)
        
        viewModel.targetCaloriesRelay
            .map { "일일 \($0)kcal 기준으로\n 탄수화물, 단백질, 지방 비율을 결정합니다." }
            .bind(to: self.subtitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.targetCaloriesRelay
            .map { CGFloat($0 / 4) }
            .bind(to: self.targetCaloriesRelayForCarbonProtein)
            .disposed(by: disposeBag)
        
        viewModel.targetCaloriesRelay
            .map { CGFloat($0 / 9) }
            .bind(to: self.targetCaloriesRelayForFat)
            .disposed(by: disposeBag)
        
        carbonSlider.userValueRelay
            .map { $0 * 4 }
            .bind(to: viewModel.userCarbonRelay)
            .disposed(by: disposeBag)
        
        proteinSlider.userValueRelay
            .map { $0 * 4 }
            .bind(to: viewModel.userProteinRelay)
            .disposed(by: disposeBag)
        
        fatSlider.userValueRelay
            .map { $0 * 9 }
            .bind(to: viewModel.userFatRelay)
            .disposed(by: disposeBag)
        
        viewModel.userCarbonRelay
            .map { Float($0 / 4) }
            .bind(to: carbonSlider.displayValueRelay)
            .disposed(by: disposeBag)
        
        viewModel.userProteinRelay
            .map { Float($0 / 4) }
            .bind(to: proteinSlider.displayValueRelay)
            .disposed(by: disposeBag)
        
        viewModel.userFatRelay
            .map { Float($0 / 9) }
            .bind(to: fatSlider.displayValueRelay)
            .disposed(by: disposeBag)
        
        viewModel.userCarbonRelay
            .map { Int($0 / 4) }
            .bind(to: carbonSlider.weightRelay)
            .disposed(by: disposeBag)
        
        viewModel.userProteinRelay
            .map { Int($0 / 4) }
            .bind(to: proteinSlider.weightRelay)
            .disposed(by: disposeBag)
        
        viewModel.userFatRelay
            .map { Int($0 / 9) }
            .bind(to: fatSlider.weightRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.userCarbonRelay,
            viewModel.userProteinRelay,
            viewModel.userFatRelay
        ) { carbon, protein, fat -> Int in
            return Int(carbon + protein + fat)
        }
        .bind(to: estimatedDailyCalorieView.calorieRelay)
        .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.viewModel.userCarbonRelay.accept(self.initialCarbon)
                self.viewModel.userProteinRelay.accept(self.initialProtein)
                self.viewModel.userFatRelay.accept(self.initialFat)
            })
            .disposed(by: disposeBag)
    }

}

final class NutritionSettingSlider: UIView {
    private let title: String
    private let sliderThumbColor: UIColor
    private let sliderBackgroundColor: UIColor
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    private let ratioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    let weightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        return label
    }()
    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.isContinuous = true
        return slider
    }()
    
    let userValueRelay = PublishRelay<Float>()
    let displayValueRelay = BehaviorRelay<Float>(value: 0)
    let weightRelay = BehaviorRelay<Int>(value: 0)
    let maximumValueRelay: BehaviorRelay<CGFloat>
    
    private let disposeBag = DisposeBag()
    
    init(title: String,
         sliderThumbColor: UIColor,
         sliderBackgroundColor: UIColor,
         maximumValueRelay: BehaviorRelay<CGFloat>) {
        self.title = title
        self.sliderThumbColor = sliderThumbColor
        self.sliderBackgroundColor = sliderBackgroundColor
        self.maximumValueRelay = maximumValueRelay
        super.init(frame: .zero)
        setUpView()
        setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        titleLabel.text = title
        ratioLabel.textColor = sliderThumbColor
        slider.thumbTintColor = sliderThumbColor
        slider.minimumTrackTintColor = sliderBackgroundColor
        slider.maximumTrackTintColor = sliderBackgroundColor
        
        [titleLabel, ratioLabel, weightLabel, slider].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        weightLabel.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
        }
        
        ratioLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalTo(weightLabel.snp.leading).offset(-8)
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    private func setUpBinding() {
        slider.rx.value
            .distinctUntilChanged()
            .bind(to: userValueRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(displayValueRelay, maximumValueRelay)
            .subscribe(onNext: { [weak self] value, maxValue in
                guard let self = self else { return }
                self.slider.maximumValue = Float(maxValue)
                
                if !self.slider.isTracking {
                    self.slider.value = value
                }
                
                let percent = (value / Float(maxValue)) * 100
                self.ratioLabel.text = String(format: "%.0f%%", percent)
            })
            .disposed(by: disposeBag)
        
        weightRelay
            .map { "(\($0)g)" }
            .bind(to: weightLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

final class NutritionGuideView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "info.circle")
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "영양소 비율 가이드"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private func makeItemLabel(nutrient: String, description: String) -> UILabel {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(
            string: "\(nutrient) : ",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        attributedText.append(NSAttributedString(
            string: description,
            attributes: [.font: UIFont.systemFont(ofSize: 14)]
        ))
        label.attributedText = attributedText
        label.numberOfLines = 0
        return label
    }
    
    private lazy var carbonLabel = makeItemLabel(nutrient: "탄수화물", description: "에너지 공급, 뇌 기능 유지 (1g = 4kcal)")
    private lazy var proteinLabel = makeItemLabel(nutrient: "단백질", description: "근육 합성, 조직 복구 (1g = 4kcal)")
    private lazy var fatLabel = makeItemLabel(nutrient: "지방", description: "호르몬 생성, 비타민 흡수 (1g = 9kcal)")
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [carbonLabel, proteinLabel, fatLabel])
        sv.axis = .vertical
        sv.spacing = 4
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(stackView)
        
        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.centerY.equalTo(iconImageView.snp.centerY)
            make.trailing.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
