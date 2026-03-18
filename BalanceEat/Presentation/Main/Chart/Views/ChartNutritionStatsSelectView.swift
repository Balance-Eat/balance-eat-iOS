//
//  ChartNutritionStatsSelectView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChartNutritionStatsSelectView: UIView {
    private let calorieButton = SelectableTitledButton(
        title: "칼로리",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .calorieText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let carbohydrateButton = SelectableTitledButton(
        title: "탄수화물",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .carbonText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let proteinButton = SelectableTitledButton(
        title: "단백질",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .proteinText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let fatButton = SelectableTitledButton(
        title: "지방",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .fatText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private lazy var nutritionButtons = [calorieButton, carbohydrateButton, proteinButton, fatButton]

    let nutritionRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        setUpView()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        calorieButton.isSelectedRelay.accept(true)

        let stackView = UIStackView(arrangedSubviews: nutritionButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setBinding() {
        for button in nutritionButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self, weak button] isSelected in
                    guard let self = self, let button = button else { return }

                    if isSelected {
                        nutritionButtons.forEach {
                            if $0 !== button {
                                $0.isSelectedRelay.accept(false)
                            }
                        }

                        switch button {
                        case calorieButton:
                            nutritionRelay.accept(.calorie)
                        case carbohydrateButton:
                            nutritionRelay.accept(.carbohydrate)
                        case proteinButton:
                            nutritionRelay.accept(.protein)
                        case fatButton:
                            nutritionRelay.accept(.fat)
                        default:
                            break
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
