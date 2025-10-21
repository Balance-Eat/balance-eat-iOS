//
//  StepperView.swift
//  BalanceEat
//
//  Created by 김견 on 9/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum StepperMode {
    case servingSize
    case amountSize
}

final class StepperView: UIView {
    var stepValue: Double = 1
    var unit: String = ""
    var servingSize: Double = 0
    let foodServingSize: Double = 0
    let stepperModeRelay: BehaviorRelay<StepperMode> = .init(value: .servingSize)
    let amountSizeRelay: BehaviorRelay<Double> = .init(value: 0)
    private let disposeBag = DisposeBag()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let minusButton: CountingButton = {
        let button = CountingButton(title: "-")
        return button
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .label
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray6.cgColor
        return textField
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    private let plusButton: CountingButton = {
        let button = CountingButton(title: "+")
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(mainStackView)
        
        [minusButton, textField, amountLabel, plusButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        minusButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        plusButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        textField.snp.makeConstraints { make in
            make.width.equalTo(52)
        }
    }
    
    private func setBinding() {
        minusButton.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                guard textField.text != "1" else { return }
                
                let currentValue = Double(textField.text ?? "") ?? 0
                let newValue = currentValue - stepValue
                textField.text = String(Int(newValue))
                textField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        plusButton.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let currentValue = Double(textField.text ?? "") ?? 0
                let newValue = currentValue + stepValue
                textField.text = String(Int(newValue))
                textField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        stepperModeRelay
            .subscribe(onNext: { [weak self] mode in
                guard let self else { return }
                
                switch mode {
                case .servingSize:
                    textField.text = "1"
                    amountLabel.text = "\(Int(servingSize))\(unit)"
                case .amountSize:
                    textField.text = String(Int(servingSize))
                    amountLabel.text = unit
                }
                textField.sendActions(for: .editingChanged)
            })
            .disposed(by: disposeBag)
        
        textField.rx.text.orEmpty
            .map { [weak self] text in
                guard let self else { return 0 }
                
                if Double(text) ?? 0 > 1000 {
                    textField.text = "1000"
                }
                
                switch self.stepperModeRelay.value {
                case .servingSize:
                    return (Double(text) ?? 0) * servingSize
                case .amountSize:
                    return Double(text) ?? 0
                }
            }
            .bind(to: amountSizeRelay)
            .disposed(by: disposeBag)
    }
}
