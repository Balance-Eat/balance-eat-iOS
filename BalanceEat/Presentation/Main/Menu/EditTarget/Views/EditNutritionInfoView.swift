//
//  EditNutritionInfoView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditNutritionInfoView: UIView {
    private let carbonField = InputFieldWithIcon(placeholder: "", unit: "g")
    private let proteinField = InputFieldWithIcon(placeholder: "", unit: "g")
    private let fatField = InputFieldWithIcon(placeholder: "", unit: "g")
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "예상 일일 소모 칼로리를 토대로 추천드리는 값입니다.\n예상 일일 소모 칼로리와 다를 수 있습니다."
        return label
    }()

    let carbonRelay: BehaviorRelay<Double> = .init(value: 0)
    let proteinRelay: BehaviorRelay<Double> = .init(value: 0)
    let fatRelay: BehaviorRelay<Double> = .init(value: 0)
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
        let mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [])
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()

        let carbonTitledInputInfoView = TitledInputInfoView(title: "탄수화물", inputView: carbonField, useBalanceEatWrapper: false)
        let proteinTitledInputInfoView = TitledInputInfoView(title: "단백질", inputView: proteinField, useBalanceEatWrapper: false)
        let fatTitledInputInfoView = TitledInputInfoView(title: "지방", inputView: fatField, useBalanceEatWrapper: false)

        [carbonTitledInputInfoView, proteinTitledInputInfoView, fatTitledInputInfoView, calorieLabel, explanationLabel].forEach(mainStackView.addArrangedSubview(_:))

        addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setBinding() {
        carbonField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: carbonRelay)
            .disposed(by: disposeBag)

        proteinField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: proteinRelay)
            .disposed(by: disposeBag)

        fatField.textObservable
            .map { Double($0 ?? "") ?? 0 }
            .bind(to: fatRelay)
            .disposed(by: disposeBag)

        Observable.combineLatest(carbonRelay, proteinRelay, fatRelay) { carbon, protein, fat in
            let carbonCalorie = carbon * 4
            let proteinCalorie = protein * 4
            let fatCalorie = fat * 9

            return carbonCalorie + proteinCalorie + fatCalorie
        }
        .map { "총: \(String(format: "%.0f", $0))kcal" }
        .bind(to: calorieLabel.rx.text)
        .disposed(by: disposeBag)
    }

    func setCarbonText(text: String) {
        carbonField.setText(text)
        carbonField.textField.sendActions(for: .editingChanged)
    }

    func setProteinText(text: String) {
        proteinField.setText(text)
        proteinField.textField.sendActions(for: .editingChanged)
    }

    func setFatText(text: String) {
        fatField.setText(text)
        fatField.textField.sendActions(for: .editingChanged)
    }
}
