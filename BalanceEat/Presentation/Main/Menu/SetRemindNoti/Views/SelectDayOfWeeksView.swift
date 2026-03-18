//
//  SelectDayOfWeeksView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SelectDayOfWeeksView: UIView {
    private let dayButtons: [DayOfWeek: SelectableTitledButton] = [
        .monday: SelectableTitledButton(title: "월", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true),
        .tuesday: SelectableTitledButton(title: "화", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true),
        .wednesday: SelectableTitledButton(title: "수", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true),
        .thursday: SelectableTitledButton(title: "목", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true),
        .friday: SelectableTitledButton(title: "금", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true),
        .saturday: SelectableTitledButton(title: "토", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true),
        .sunday: SelectableTitledButton(title: "일", style: .init(backgroundColor: .lightGray.withAlphaComponent(0.3), titleColor: .black, borderColor: nil, gradientColors: nil, selectedBackgroundColor: .systemBlue, selectedTitleColor: .white, selectedBorderColor: nil, selectedGradientColors: nil), isCancellable: true)
    ]

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
        let orderedDays: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let orderedButtons = orderedDays.compactMap { dayButtons[$0] }

        let mainStackView = UIStackView(arrangedSubviews: orderedButtons)
        mainStackView.axis = .horizontal
        mainStackView.spacing = 8
        mainStackView.distribution = .fillEqually

        addSubview(mainStackView)

        orderedButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.equalTo(60)
            }
        }

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setBinding() {
        for (day, button) in dayButtons {
            button.tapRelay
                .withLatestFrom(selectedDays)
                .subscribe(onNext: { [weak self] current in
                    guard let self else { return }

                    var updated = current
                    if updated.contains(day) {
                        updated.remove(day)
                    } else {
                        updated.insert(day)
                    }
                    self.selectedDays.accept(updated)
                })
                .disposed(by: disposeBag)
        }

        selectedDays
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] days in
                guard let self else { return }
                for (day, button) in self.dayButtons {
                    button.isSelectedRelay.accept(days.contains(day))
                }
            })
            .disposed(by: disposeBag)
    }
}
