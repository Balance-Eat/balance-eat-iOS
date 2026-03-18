//
//  BMIView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BMIView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "예상 BMI"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let currentWeightLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .red
        return label
    }()
    private let evaluationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    private let bmiSourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.text = "BMI 기준: 세계보건기구(WHO) 권장 지침 참고"
        return label
    }()
    private let sourceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("출처 보기", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.addTarget(nil, action: #selector(openSource), for: .touchUpInside)
        return button
    }()

    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    let heightRelay: BehaviorRelay<Double> = .init(value: 0)
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
        self.backgroundColor = .red.withAlphaComponent(0.05)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.withAlphaComponent(0.1).cgColor

        let leftStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, currentWeightLabel])
            stackView.axis = .vertical
            stackView.spacing = 4
            return stackView
        }()

        let rightStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [valueLabel, evaluationLabel])
            stackView.axis = .vertical
            stackView.spacing = 4
            stackView.alignment = .trailing
            return stackView
        }()

        [leftStackView, rightStackView, bmiSourceLabel, sourceButton].forEach(addSubview(_:))

        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }

        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(12)
        }

        bmiSourceLabel.snp.makeConstraints { make in
            make.top.equalTo(rightStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(16)
        }

        sourceButton.snp.makeConstraints { make in
            make.top.equalTo(bmiSourceLabel.snp.bottom)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    private func setBinding() {
        Observable.combineLatest(heightRelay, userDataRelay)
            .subscribe(onNext: { [weak self] (height, userData) in
                guard let self else { return }
                guard let weight = userData?.weight else { return }

                currentWeightLabel.text = "현재 체중 \(String(format: "%.1f", userData?.weight ?? 0))kg 기준"
                let bmi = weight / (pow(height, 2) * 0.0001)

                valueLabel.text = height == 0 ? "-" : String(format: "%.1f", bmi)

                if bmi < 18.5 {
                    evaluationLabel.text = "저체중"
                } else if bmi >= 18.5 && bmi <= 24.9 {
                    evaluationLabel.text = "정상"
                } else if bmi >= 25 && bmi <= 29.9 {
                    evaluationLabel.text = "과체중"
                } else {
                    evaluationLabel.text = "비만"
                }
            })
            .disposed(by: disposeBag)
    }

    @objc private func openSource() {
        guard let url = URL(string: "https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight") else { return }
        UIApplication.shared.open(url)
    }
}
