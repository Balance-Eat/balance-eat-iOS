//
//  ChartStatStackView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChartStatStackView: UIView {
    private let averageStatAmountView = ChartStatAmountView(title: "평균")
    private let maxStatAmountView = ChartStatAmountView(title: "최고", isMax: true)
    private let minStatAmountView = ChartStatAmountView(title: "최저", isMin: true)

    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    private let averageAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    private let maxAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    private let minAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
        let stackView = UIStackView(arrangedSubviews: [averageStatAmountView, maxStatAmountView, minStatAmountView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setBinding() {
        averageAmountRelay
            .bind(to: averageStatAmountView.amountRelay)
            .disposed(by: disposeBag)

        maxAmountRelay
            .bind(to: maxStatAmountView.amountRelay)
            .disposed(by: disposeBag)

        minAmountRelay
            .bind(to: minStatAmountView.amountRelay)
            .disposed(by: disposeBag)

        Observable.combineLatest(statsRelay, nutritionStatTypeRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType in
                guard let self, !stats.isEmpty else { return }
                var sum: Double = 0
                var max: Double = 0
                var min: Double = 0

                switch nutritionStatType {
                case .calorie:
                    sum = stats.reduce(0) { $0 + $1.totalCalories }
                    max = stats.map(\.totalCalories).max() ?? 0
                    min = stats.map(\.totalCalories).min() ?? 0
                case .carbohydrate:
                    sum = stats.reduce(0) { $0 + $1.totalCarbohydrates }
                    max = stats.map(\.totalCarbohydrates).max() ?? 0
                    min = stats.map(\.totalCarbohydrates).min() ?? 0
                case .protein:
                    sum = stats.reduce(0) { $0 + $1.totalProtein }
                    max = stats.map(\.totalProtein).max() ?? 0
                    min = stats.map(\.totalProtein).min() ?? 0
                case .fat:
                    sum = stats.reduce(0) { $0 + $1.totalFat }
                    max = stats.map(\.totalFat).max() ?? 0
                    min = stats.map(\.totalFat).min() ?? 0
                }

                averageAmountRelay.accept(sum / Double(stats.count))
                maxAmountRelay.accept(max)
                minAmountRelay.accept(min)

                [averageStatAmountView, maxStatAmountView, minStatAmountView].forEach {
                    $0.statRelay.accept(nutritionStatType)
                }
            })
            .disposed(by: disposeBag)
    }
}
