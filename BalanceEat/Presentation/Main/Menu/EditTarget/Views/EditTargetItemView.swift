//
//  EditTargetItemView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditTargetItemView: UIView {
    private let editTargetItemType: EditTargetItemType

    private lazy var currentField = InputFieldWithIcon(placeholder: "", unit: editTargetItemType == .fatPercentage ? "%" : "kg", isFat: editTargetItemType == .fatPercentage)
    private lazy var targetField = InputFieldWithIcon(placeholder: "", unit: editTargetItemType == .fatPercentage ? "%" : "kg", isFat: editTargetItemType == .fatPercentage)

    var currentText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var targetText: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    init(editTargetItemType: EditTargetItemType) {
        self.editTargetItemType = editTargetItemType

        super.init(frame: .zero)
        setUpView()
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

        let currentTitledInputUserInfoView = TitledInputInfoView(title: "현재 \(editTargetItemType.title)", inputView: currentField, useBalanceEatWrapper: false)

        currentField.textObservable
            .bind(to: currentText)
            .disposed(by: disposeBag)

        let targetTitledInputUserInfoView = TitledInputInfoView(title: "목표 \(editTargetItemType.title)", inputView: targetField, useBalanceEatWrapper: false)

        targetField.textObservable
            .bind(to: targetText)
            .disposed(by: disposeBag)

        let fieldStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [currentTitledInputUserInfoView, targetTitledInputUserInfoView])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            return stackView
        }()

        mainStackView.addArrangedSubview(fieldStackView)

        let diffLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .systemGray
            label.textAlignment = .center
            label.layer.cornerRadius = 8
            label.layer.masksToBounds = true
            return label
        }()
        diffLabel.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        mainStackView.addArrangedSubview(diffLabel)

        Observable.combineLatest(currentText, targetText) { current, target -> Double? in
            guard let currentValue = Double(current ?? ""), let targetValue = Double(target ?? "") else {
                return nil
            }
            return targetValue - currentValue
        }
        .subscribe(onNext: { [weak self] (diff: Double?) in
            guard let self else { return }

            if let diff = diff {
                if diff > 0 {
                    diffLabel.text = String(format: "%.1f%@ 증가", diff, self.editTargetItemType.unit)
                    diffLabel.textColor = .systemBlue
                    diffLabel.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.1)
                } else if diff < 0 {
                    diffLabel.text = String(format: "%.1f%@ 감소", abs(diff), self.editTargetItemType.unit)
                    diffLabel.textColor = .systemRed
                    diffLabel.backgroundColor = UIColor.appDestructive.withAlphaComponent(0.1)
                } else {
                    diffLabel.text = "변화 없음"
                    diffLabel.textColor = .systemGray
                    diffLabel.backgroundColor = UIColor.appNeutral.withAlphaComponent(0.1)
                }
            } else {
                let currentString = currentText.value ?? ""
                let targetString = targetText.value ?? ""
                let title = self.editTargetItemType.title
                let labelText = (currentString.isEmpty && targetString.isEmpty) ? "\(title)을 입력해주세요." : currentString.isEmpty ? "현재 \(title)을 입력해주세요." : "목표 \(title)을 입력해주세요."
                diffLabel.text = labelText
                diffLabel.textColor = .systemGray
                diffLabel.backgroundColor = UIColor.appNeutral.withAlphaComponent(0.1)
            }
        })
        .disposed(by: disposeBag)

        addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setCurrentText(_ text: String) {
        currentText.accept(text)
        currentField.setText(text)
    }

    func setTargetText(_ text: String) {
        targetText.accept(text)
        targetField.setText(text)
    }
}
