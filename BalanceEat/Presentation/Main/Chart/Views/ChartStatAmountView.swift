//
//  ChartStatAmountView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChartStatAmountView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        return label
    }()

    let amountRelay: BehaviorRelay<Double> = .init(value: 0)
    let statRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    private let disposeBag = DisposeBag()

    init(title: String, isMax: Bool = false, isMin: Bool = false) {
        super.init()
        titleLabel.text = title
        amountLabel.textColor = isMax ? .blue : isMin ? .red : .black

        setUpView()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel, unitLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        amountRelay
            .map { String(format: "%.0f", $0) }
            .bind(to: amountLabel.rx.text)
            .disposed(by: disposeBag)

        statRelay
            .subscribe(onNext: { [weak self] stat in
                guard let self else { return }

                switch stat {
                case .calorie:
                    unitLabel.text = "kcal"
                case .carbohydrate, .protein, .fat:
                    unitLabel.text = "g"
                }
            })
            .disposed(by: disposeBag)
    }
}
