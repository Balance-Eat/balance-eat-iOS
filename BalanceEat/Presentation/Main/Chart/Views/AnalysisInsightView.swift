//
//  AnalysisInsightView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AnalysisInsightView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .blue.withAlphaComponent(0.8)
        label.text = "💡 분석 인사이트"
        return label
    }()
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .blue
        label.numberOfLines = 0
        return label
    }()

    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
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
        self.backgroundColor = .blue.withAlphaComponent(0.03)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.appPrimary.withAlphaComponent(0.1).cgColor

        [titleLabel, contentLabel].forEach(addSubview(_:))

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay, userDataRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType, userData in
                guard let self, !stats.isEmpty else { return }

                var average: Double = 0
                var target: Double = 0
                var isInTargetCount: Int = 0

                switch nutritionStatType {
                case .calorie:
                    average = stats.map(\.totalCalories).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetCalorie ?? 1)
                    isInTargetCount = stats.filter { $0.totalCalories <= target }.count
                case .carbohydrate:
                    average = stats.map(\.totalCarbohydrates).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetCarbohydrates ?? 1)
                    isInTargetCount = stats.filter { $0.totalCarbohydrates <= target }.count
                case .protein:
                    average = stats.map(\.totalProtein).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetProtein ?? 1)
                    isInTargetCount = stats.filter { $0.totalProtein <= target }.count
                case .fat:
                    average = stats.map(\.totalFat).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetFat ?? 1)
                    isInTargetCount = stats.filter { $0.totalFat <= target }.count
                }

                let percentDiff = target > 0 ? abs((average - target) / target) * 100 : 0
                let comparison = average >= target ? "초과" : "미달"
                let contentString = """
                                • 평균 \(String(format: "%.0f", average))\(nutritionStatType.unit)로 목표 대비 \(String(format: "%.1f", percentDiff))% \(comparison)입니다.
                                • \(isInTargetCount)일이 목표 범위 내에 있습니다.
                                """
                contentLabel.setTextWithLineSpacing(contentString, lineSpacing: 6)
            })
            .disposed(by: disposeBag)
    }
}
