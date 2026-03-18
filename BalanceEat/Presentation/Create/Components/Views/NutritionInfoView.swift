//
//  NutritionInfoView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class NutritionInfoView: UIView {
    private let nutritionType: NutritionType

    private lazy var textColor: UIColor = {
        switch nutritionType {
        case .calorie: .calorieText
        case .carbon: .carbonText
        case .protein: .proteinText
        case .fat: .fatText
        }
    }()
    private lazy var titleString: String = {
        switch nutritionType {
        case .calorie: "칼로리"
        case .carbon: "탄수화물"
        case .protein: "단백질"
        case .fat: "지방"
        }
    }()
    private lazy var viewBackgroundColor: UIColor = {
        switch nutritionType {
        case .calorie: .calorieText.withAlphaComponent(0.1)
        case .carbon: .carbonText.withAlphaComponent(0.1)
        case .protein: .proteinText.withAlphaComponent(0.1)
        case .fat: .fatText.withAlphaComponent(0.1)
        }
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleString
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    let valueRelay = BehaviorRelay<Double>(value: 0)

    var valueTextSize: CGFloat = 16 {
        didSet { valueLabel.font = .systemFont(ofSize: valueTextSize, weight: .bold) }
    }
    var titleTextSize: CGFloat = 12 {
        didSet { titleLabel.font = .systemFont(ofSize: titleTextSize, weight: .regular) }
    }
    var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }

    private let disposeBag = DisposeBag()

    init(nutritionType: NutritionType) {
        self.nutritionType = nutritionType
        super.init(frame: .zero)

        setUpView()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        self.backgroundColor = viewBackgroundColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center

        self.addSubview(stackView)

        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)

        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }

    private func setBinding() {
        valueRelay
            .map { value -> String in
                if value.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(format: "%.0f", value) + (self.nutritionType == .calorie ? "" : "g")
                } else {
                    return String(format: "%.1f", value) + (self.nutritionType == .calorie ? "" : "g")
                }
            }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
