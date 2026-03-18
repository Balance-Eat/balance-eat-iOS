//
//  AchievementRateListView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AchievementRateListView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.text = "목표 달성률"
        return label
    }()
    private let tableView = UITableView()
    private var tableHeightConstraint: Constraint?

    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)

    let achievementRateStatsRelay: BehaviorRelay<[AchievementRateStat]> = .init(value: [])
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
        [titleLabel, tableView].forEach(addSubview(_:))

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(4)
            self.tableHeightConstraint = make.height.equalTo(0).constraint
        }

        tableView.backgroundColor = .clear
        tableView.register(AchievementRateCell.self, forCellReuseIdentifier: "AchievementRateCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }

    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay, userDataRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType, userData in
                guard let self else { return }

                var achievementRateStats: [AchievementRateStat] = []

                for (index, stat) in stats.enumerated() {
                    var date: String = ""
                    var percent: Double = 0.0

                    let isLast = index == stats.count - 1

                    if isLast {
                        switch stat.type {
                        case .daily:
                            date = "오늘"
                        case .weekly:
                            date = "이번 주"
                        case .monthly:
                            date = "이번 달"
                        }
                    } else {
                        date = extractMonthAndDay(period: stat.type, from: stat.date)
                    }

                    switch nutritionStatType {
                    case .calorie:
                        percent = (stat.totalCalories / Double((userData?.targetCalorie ?? 1))) * 100
                    case .carbohydrate:
                        percent = (stat.totalCarbohydrates / (userData?.targetCarbohydrates ?? 1)) * 100
                    case .protein:
                        percent = (stat.totalProtein / (userData?.targetProtein ?? 1)) * 100
                    case .fat:
                        percent = (stat.totalFat / (userData?.targetFat ?? 1)) * 100
                    }

                    achievementRateStats.append(AchievementRateStat(date: date, percent: percent))
                }

                achievementRateStatsRelay.accept(achievementRateStats)
            })
            .disposed(by: disposeBag)

        achievementRateStatsRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: "AchievementRateCell",
                cellType: AchievementRateCell.self)
            ) { _, stat, cell in
                cell.configure(stat: stat)
            }
            .disposed(by: disposeBag)

        tableView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0?.height }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] height in
                self?.tableHeightConstraint?.update(offset: height)
                self?.layoutIfNeeded()
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
