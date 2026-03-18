//
//  ChartHeaderView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChartHeaderView: UIView {
    private let chartPeriodSelectView = ChartPeriodSelectView()
    private let chartNutritionStatsSelectView = ChartNutritionStatsSelectView()

    let periodRelay: BehaviorRelay<Period> = .init(value: .daily)
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        setUpView()
        setBinding()
    }

    private func setUpView() {
        backgroundColor = .white

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16

        [chartPeriodSelectView, chartNutritionStatsSelectView].forEach {
            stackView.addArrangedSubview($0)

            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray.withAlphaComponent(0.2)
            separatorView.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
            stackView.addArrangedSubview(separatorView)
        }

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    private func setBinding() {
        chartPeriodSelectView.periodRelay
            .bind(to: periodRelay)
            .disposed(by: disposeBag)

        chartNutritionStatsSelectView.nutritionRelay
            .bind(to: nutritionStatTypeRelay)
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
