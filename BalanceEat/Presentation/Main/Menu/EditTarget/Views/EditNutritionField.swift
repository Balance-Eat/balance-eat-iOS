//
//  EditNutritionField.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditNutritionField: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.textAlignment = .center
        return textField
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    let textRelay: BehaviorRelay<String> = .init(value: "")
    private let disposeBag = DisposeBag()

    init(placeholder: String, unit: String) {
        textField.placeholder = placeholder
        subTitleLabel.text = unit
        super.init(frame: .zero)

        setUpView()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor

        [textField, subTitleLabel].forEach(addSubview(_:))

        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }

        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing)
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }

                if Double(text) ?? 0 >= 1000 {
                    self.textField.text = "999"
                }

                textRelay.accept(text)
            })
            .disposed(by: disposeBag)
    }

    func setText(text: String) {
        textField.text = text
        textField.sendActions(for: .editingChanged)
    }
}
