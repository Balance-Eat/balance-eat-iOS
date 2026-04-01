//
//  ChartPeriodSelectView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChartPeriodSelectView: UIView {
    private let dailyButton = SelectableTitledButton(
        title: "일별",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.3),
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let weeklyButton = SelectableTitledButton(
        title: "주별", style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.3),
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let monthlyButton = SelectableTitledButton(
        title: "월별", style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.3),
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )

    private lazy var periodButtons = [dailyButton, weeklyButton, monthlyButton]

    let periodRelay: BehaviorRelay<Period> = .init(value: .daily)
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
        dailyButton.isSelectedRelay.accept(true)

        let stackView = UIStackView(arrangedSubviews: periodButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setBinding() {
        for button in periodButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self] isSelected in
                    guard let self else { return }
                    guard isSelected else { return }

                    self.periodButtons.forEach {
                        if $0 !== button {
                            $0.isSelectedRelay.accept(false)
                        }
                    }

                    switch button {
                    case self.dailyButton:
                        self.periodRelay.accept(.daily)
                    case self.weeklyButton:
                        self.periodRelay.accept(.weekly)
                    case self.monthlyButton:
                        self.periodRelay.accept(.monthly)
                    default:
                        break
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
