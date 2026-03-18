//
//  StatsGraphView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import DGCharts

final class StatsGraphView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let lineChartView: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()

    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
        addSubview(titleLabel)
        addSubview(lineChartView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(16)
        }

        lineChartView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType in
                guard let self else { return }

                var entries: [ChartDataEntry] = []
                let labels = stats.enumerated().map { [weak self] (index, stat) in
                    guard let self else { return "" }

                    let isLast = index == stats.count - 1

                    switch stat.type {
                    case .daily:
                        if isLast { return "오늘" }
                    case .weekly:
                        if isLast { return "이번 주" }
                    case .monthly:
                        if isLast { return "이번 달" }
                    }

                    return extractMonthAndDay(period: stat.type, from: stat.date)
                }

                for i in 0..<stats.count {
                    switch nutritionStatType {
                    case .calorie:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalCalories))
                    case .carbohydrate:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalCarbohydrates))
                    case .protein:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalProtein))
                    case .fat:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalFat))
                    }
                }

                var label: String
                var color: UIColor

                switch nutritionStatType {
                case .calorie:
                    label = "칼로리"
                    color = .calorieText
                    titleLabel.text = "칼로리 추이"
                case .carbohydrate:
                    label = "탄수화물"
                    color = .carbonText
                    titleLabel.text = "탄수화물 추이"
                case .protein:
                    label = "단백질"
                    color = .proteinText
                    titleLabel.text = "단백질 추이"
                case .fat:
                    label = "지방"
                    color = .fatText
                    titleLabel.text = "지방 추이"
                }

                let dataSet = LineChartDataSet(entries: entries, label: label)
                dataSet.colors = [color]
                dataSet.circleColors = [.systemBlue]
                dataSet.lineWidth = 2
                dataSet.circleRadius = 5
                dataSet.mode = .linear

                let data = LineChartData(dataSet: dataSet)
                lineChartView.data = data

                lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
                lineChartView.xAxis.granularity = 1
                lineChartView.xAxis.labelPosition = .bottom

                lineChartView.rightAxis.enabled = false
                lineChartView.notifyDataSetChanged()

                let count = Double(labels.count)
                lineChartView.xAxis.axisMinimum = -0.5
                lineChartView.xAxis.axisMaximum = count - 0.5
            })
            .disposed(by: disposeBag)
    }

    private func extractMonthAndDay(period: Period, from dateString: String) -> String {
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return "" }

        if period == .monthly {
            return "\(components[0].suffix(2))-\(components[1])"
        } else {
            return "\(components[1])-\(components[2])"
        }
    }
}
