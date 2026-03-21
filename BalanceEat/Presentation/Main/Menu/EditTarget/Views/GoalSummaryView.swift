//
//  GoalSummaryView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class GoalSummaryView: UIView {
    private let titleStackView: UIStackView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "목표 요약"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .black

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fill

        return stackView
    }()
    private lazy var targetsStackView: UIStackView = {
        let weightGoalSummaryContentView = GoalSummaryContentView(
            editTargetItemType: .weight,
            currentRelay: currentWeightRelay,
            targetRelay: targetWeightRelay
        )
        let smiGoalSummaryContentView = GoalSummaryContentView(
            editTargetItemType: .smi,
            currentRelay: currentSMIRelay,
            targetRelay: targetSMIRelay
        )
        let fatPercentageGoalSummaryContentView = GoalSummaryContentView(
            editTargetItemType: .fatPercentage,
            currentRelay: currentFatPercentageRelay,
            targetRelay: targetFatPercentageRelay
        )
        let stackView = UIStackView(arrangedSubviews: [
            weightGoalSummaryContentView,
            smiGoalSummaryContentView,
            fatPercentageGoalSummaryContentView
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private let currentWeightRelay: BehaviorRelay<Double?>
    private let targetWeightRelay: BehaviorRelay<Double?>
    private let currentSMIRelay: BehaviorRelay<Double?>
    private let targetSMIRelay: BehaviorRelay<Double?>
    private let currentFatPercentageRelay: BehaviorRelay<Double?>
    private let targetFatPercentageRelay: BehaviorRelay<Double?>

    private let disposeBag = DisposeBag()

    init(
        currentWeightRelay: BehaviorRelay<Double?>,
        targetWeightRelay: BehaviorRelay<Double?>,
        currentSMIRelay: BehaviorRelay<Double?>,
        targetSMIRelay: BehaviorRelay<Double?>,
        currentFatPercentageRelay: BehaviorRelay<Double?>,
        targetFatPercentageRelay: BehaviorRelay<Double?>
    ) {
        self.currentWeightRelay = currentWeightRelay
        self.targetWeightRelay = targetWeightRelay
        self.currentSMIRelay = currentSMIRelay
        self.targetSMIRelay = targetSMIRelay
        self.currentFatPercentageRelay = currentFatPercentageRelay
        self.targetFatPercentageRelay = targetFatPercentageRelay
        super.init(frame: .zero)

        self.backgroundColor = .systemBlue.withAlphaComponent(0.05)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.appPrimary.withAlphaComponent(0.4).cgColor

        [titleStackView, targetsStackView].forEach { addSubview($0) }

        titleStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(24)
        }

        targetsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
