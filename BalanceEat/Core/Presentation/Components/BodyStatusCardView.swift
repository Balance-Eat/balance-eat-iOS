//
//  BodyStatusCardView.swift
//  BalanceEat
//
//  Created by 김견 on 7/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BodyStatusCardView: UIView {
    private let title: String
    private var weight: Double
    private var smi: Double?
    private var fatPercentage: Double?
    private let isTarget: Bool
    
    private let containerView: BalanceEatContentView = BalanceEatContentView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .bodyStatusCardTitle
        return label
    }()
    
    private let goToEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private lazy var weightLabel: StatusLabel = {
        let label = StatusLabel(number: weight, unit: "kg", isWeight: true, isTarget: isTarget)
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    private let subMetricsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var smiLabel = StatusLabel(number: smi, unit: "kg", isTarget: isTarget)
    private lazy var fatLabel = StatusLabel(number: fatPercentage, unit: "%", isTarget: isTarget)
    
    private lazy var smiView: UIStackView = {
        let titleLabel = UILabel()
        titleLabel.text = "골격근량"
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .bodyStatusCartSubtitle
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, smiLabel])
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()
    
    private lazy var fatView: UIStackView = {
        let titleLabel = UILabel()
        titleLabel.text = "체지방율"
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .bodyStatusCartSubtitle
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, fatLabel])
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()
    
    let goToEditTapRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(title: String, weight: Double, smi: Double?, fatPercentage: Double?, isTarget: Bool = false) {
        self.title = title
        self.weight = weight
        self.smi = smi
        self.fatPercentage = fatPercentage
        self.isTarget = isTarget
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(containerView)
        
        [titleLabel, goToEditButton, weightLabel, separatorView, subMetricsStackView].forEach {
            containerView.addSubview($0)
        }
        
        subMetricsStackView.addArrangedSubview(smiView)
        subMetricsStackView.addArrangedSubview(fatView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        
        goToEditButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(16)
        }
        
        weightLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(weightLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        subMetricsStackView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func setBinding() {
        goToEditButton.rx.tap
            .bind(to: goToEditTapRelay)
            .disposed(by: disposeBag)
    }
    
    func update(weight: Double, smi: Double?, fatPercentage: Double?) {
        self.weight = weight
        self.smi = smi
        self.fatPercentage = fatPercentage

        weightLabel.updateNumber(number: weight)
        smiLabel.updateNumber(number: smi ?? 0)
        fatLabel.updateNumber(number: fatPercentage ?? 0)
    }
}

final class StatusLabel: UILabel {
    private var number: Double?
    private let unit: String
    private let isWeight: Bool
    private let isTarget: Bool

    private lazy var numberFont: UIFont = .systemFont(ofSize: isWeight ? 24 : 14, weight: .bold)
    private let numberColor: UIColor = .bodyStatusCardNumber

    private let unitFont: UIFont = .systemFont(ofSize: 12, weight: .bold)
    private let unitColor: UIColor = .bodyStatusCardUnit

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    init(number: Double?, unit: String, isWeight: Bool = false, isTarget: Bool = false) {
        self.number = number
        self.unit = unit
        self.isWeight = isWeight
        self.isTarget = isTarget
        super.init(frame: .zero)
        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        var prefix = ""
        if isTarget && number ?? 0 > 0 {
            prefix = "+"
        }
        let numberString: String
        if number == nil {
            numberString = "-"
        } else if let formatted = numberFormatter.string(from: NSNumber(value: number ?? 0)) {
            numberString = formatted
        } else {
            numberString = "\(number ?? 0)"
        }

        let fullText = "\(prefix)\(numberString)\(unit)"
        let attributedText = NSMutableAttributedString(string: fullText)

        attributedText.addAttributes([
            .font: numberFont,
            .foregroundColor: numberColor
        ], range: NSRange(location: 0, length: prefix.count + numberString.count))

        attributedText.addAttributes([
            .font: unitFont,
            .foregroundColor: unitColor
        ], range: NSRange(location: prefix.count + numberString.count, length: unit.count))

        self.attributedText = attributedText
    }

    func updateNumber(number: Double) {
        self.number = number
        setupLabel()
    }
}
