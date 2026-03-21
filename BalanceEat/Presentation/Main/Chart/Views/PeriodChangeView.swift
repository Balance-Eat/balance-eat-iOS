//
//  PeriodChangeView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PeriodChangeView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.text = "기간 대비 변화"
        return label
    }()
    private let periodChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let differenceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()
    private let differenceContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    private let disposeBag = DisposeBag()

    override init() {
        super.init()

        setUpView()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        differenceContainerView.addSubview(differenceLabel)

        differenceLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        [titleLabel, periodChangeLabel, differenceContainerView].forEach {
            addSubview($0)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        differenceContainerView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }

        periodChangeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatRelay)
            .subscribe(onNext: { [weak self] statsDatas, nutritionStat in
                guard let self else { return }
                let firstDate = extractMonthAndDay(from: statsDatas.first?.date ?? "")
                var firstNutritionAmount: Double = 0
                let lastDate = extractMonthAndDay(from: statsDatas.last?.date ?? "")
                var lastNutritionAmount: Double = 0

                switch nutritionStat {
                case .calorie:
                    firstNutritionAmount = statsDatas.first?.totalCalories ?? 0
                    lastNutritionAmount = statsDatas.last?.totalCalories ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)kcal → \(lastDate): \(lastNutritionAmount)kcal"
                case .carbohydrate:
                    firstNutritionAmount = statsDatas.first?.totalCarbohydrates ?? 0
                    lastNutritionAmount = statsDatas.last?.totalCarbohydrates ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)g → \(lastDate): \(lastNutritionAmount)g"
                case .protein:
                    firstNutritionAmount = statsDatas.first?.totalProtein ?? 0
                    lastNutritionAmount = statsDatas.last?.totalProtein ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)g → \(lastDate): \(lastNutritionAmount)g"
                case .fat:
                    firstNutritionAmount = statsDatas.first?.totalFat ?? 0
                    lastNutritionAmount = statsDatas.last?.totalFat ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)g → \(lastDate): \(lastNutritionAmount)g"
                }

                let diff = lastNutritionAmount - firstNutritionAmount

                if diff > 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 증가", diff, nutritionStat.unit)
                    self.differenceLabel.textColor = .systemBlue
                    self.differenceContainerView.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.1)
                } else if diff < 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 감소", abs(diff), nutritionStat.unit)
                    self.differenceLabel.textColor = .systemRed
                    self.differenceContainerView.backgroundColor = UIColor.appDestructive.withAlphaComponent(0.1)
                } else {
                    self.differenceLabel.text = "변화 없음"
                    self.differenceLabel.textColor = .systemGray
                    self.differenceContainerView.backgroundColor = UIColor.appNeutral.withAlphaComponent(0.1)
                }
            })
            .disposed(by: disposeBag)
    }

    private func extractMonthAndDay(from dateString: String) -> String {
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return "" }
        return "\(components[1])-\(components[2])"
    }
}
