//
//  AddedFoodCell.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddedFoodCell: UITableViewCell {
    private var foodData: DietFoodData?
    private var intake: Double = 0

    private let containerView = UIView()

    private let foodNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let foodServingSizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()

    private let twoOptionPickerView = TwoOptionPickerView(firstText: "1인분", secondText: "단위")
    private let stepperView = StepperView()
    private let nutritionalInfoView: TotalNutritionalInfoView

    let nutritionRelay = BehaviorRelay<(Double, Double, Double, Double)>(value: (0, 0, 0, 0))
    let intakeRelay = BehaviorRelay<Double>(value: 0)
    let closeButtonTapped = PublishRelay<Void>()

    var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.nutritionalInfoView = TotalNutritionalInfoView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func setupView() {
        self.backgroundColor = .clear
        contentView.addSubview(containerView)

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.appBorder.withAlphaComponent(0.1).cgColor

        containerView.addSubview(foodNameLabel)
        containerView.addSubview(foodServingSizeLabel)
        containerView.addSubview(twoOptionPickerView)
        containerView.addSubview(stepperView)
        containerView.addSubview(closeButton)
        containerView.addSubview(nutritionalInfoView)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview()
        }

        foodNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }

        foodServingSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(foodNameLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }

        let inputStackView = UIStackView(arrangedSubviews: [twoOptionPickerView, stepperView])
        inputStackView.axis = .horizontal
        inputStackView.distribution = .equalSpacing
        inputStackView.spacing = 8

        addSubview(inputStackView)

        inputStackView.snp.makeConstraints { make in
            make.top.equalTo(foodServingSizeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        nutritionalInfoView.snp.makeConstraints { make in
            make.top.equalTo(twoOptionPickerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(foodData: DietFoodData) {
        prepareForReuse()

        foodNameLabel.text = foodData.name
        foodServingSizeLabel.text = "1인분: \(foodData.servingSize)\(foodData.unit)"
        self.intake = foodData.intake
        self.foodData = foodData

        stepperView.unit = foodData.unit
        stepperView.intake = intake
        stepperView.servingSize = foodData.servingSize

        nutritionalInfoView.calorieRelay.accept(foodData.calories)
        nutritionalInfoView.carbonRelay.accept(foodData.carbohydrates)
        nutritionalInfoView.proteinRelay.accept(foodData.protein)
        nutritionalInfoView.fatRelay.accept(foodData.fat)

        closeButton.rx.tap
            .bind(to: closeButtonTapped)
            .disposed(by: disposeBag)

        twoOptionPickerView.selectedOption
            .subscribe(onNext: { [weak self] selectedOption in
                guard let self else { return }

                let stepValue = foodData.intake > 0 ? intake / foodData.intake : 1.0
                switch selectedOption {
                case .first:
                    stepperView.stepValue = stepValue
                    stepperView.stepperModeRelay.accept(.servingSize)
                case .second:
                    stepperView.stepValue = stepValue
                    stepperView.stepperModeRelay.accept(.amountSize)
                }
            })
            .disposed(by: disposeBag)

        stepperView.intakeRelay
            .subscribe(onNext: { [weak self] amount in
                guard let self else { return }
                guard let foodData = self.foodData else { return }

                let ratio = amount / intake

                nutritionalInfoView.calorieRelay.accept(foodData.calories * ratio)
                nutritionalInfoView.carbonRelay.accept(foodData.carbohydrates * ratio)
                nutritionalInfoView.proteinRelay.accept(foodData.protein * ratio)
                nutritionalInfoView.fatRelay.accept(foodData.fat * ratio)

                intakeRelay.accept(amount)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            nutritionalInfoView.calorieRelay,
            nutritionalInfoView.carbonRelay,
            nutritionalInfoView.proteinRelay,
            nutritionalInfoView.fatRelay
        )
        .subscribe(onNext: { [weak self] (cal, carbon, protein, fat) in
            guard let self else { return }
            self.nutritionRelay.accept((cal, carbon, protein, fat))
        })
        .disposed(by: disposeBag)
    }
}
