//
//  SetNotiRepeatDayOfWeekView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum DayOfWeekQuickType {
    case everyDay
    case weekdays
    case weekend
}

final class SetNotiRepeatDayOfWeekView: UIView {
    private let everydayButton = TitledButton(
        title: "매일",
        style: .init(
            backgroundColor: nil,
            titleColor: .black,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.7), .red.withAlphaComponent(0.3)]
        )
    )
    private let weekdaysButton = TitledButton(
        title: "평일",
        style: .init(
            backgroundColor: nil,
            titleColor: .black,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.7), .red.withAlphaComponent(0.3)]
        )
    )
    private let weekendButton = TitledButton(
        title: "주말",
        style: .init(
            backgroundColor: nil,
            titleColor: .black,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.7), .red.withAlphaComponent(0.3)]
        )
    )
    private lazy var selectDayOfWeeksView = SelectDayOfWeeksView(selectedDays: selectedDays)

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitle(" 초기화", for: .normal)
        button.tintColor = .lightGray
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let selectedDays: BehaviorRelay<Set<DayOfWeek>>
    private let disposeBag = DisposeBag()

    init(selectedDays: BehaviorRelay<Set<DayOfWeek>>) {
        self.selectedDays = selectedDays
        super.init(frame: .zero)

        setUpView()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        let quickTypeStackView = UIStackView(arrangedSubviews: [everydayButton, weekdaysButton, weekendButton])
        quickTypeStackView.axis = .horizontal
        quickTypeStackView.spacing = 8
        quickTypeStackView.distribution = .fillEqually

        let mainStackView = UIStackView(arrangedSubviews: [quickTypeStackView, selectDayOfWeeksView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.alignment = .leading

        addSubview(mainStackView)
        addSubview(resetButton)

        everydayButton.snp.makeConstraints { make in make.width.equalTo(60) }
        weekdaysButton.snp.makeConstraints { make in make.width.equalTo(60) }
        weekendButton.snp.makeConstraints { make in make.width.equalTo(60) }

        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        resetButton.snp.makeConstraints { make in
            make.top.equalTo(mainStackView.snp.bottom).offset(8)
            make.trailing.bottom.equalToSuperview()
        }
    }

    private func setBinding() {
        everydayButton.rx.tap
            .map { Set([DayOfWeek.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)

        weekdaysButton.rx.tap
            .map { Set([DayOfWeek.monday, .tuesday, .wednesday, .thursday, .friday]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)

        weekendButton.rx.tap
            .map { Set([DayOfWeek.saturday, .sunday]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)

        resetButton.rx.tap
            .map { Set<DayOfWeek>([]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)
    }
}
