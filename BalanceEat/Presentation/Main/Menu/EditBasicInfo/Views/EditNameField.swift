//
//  EditNameField.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditNameField: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름"
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray4
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    let textRelay: BehaviorRelay<String> = .init(value: "")
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
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor

        [textField, textCountLabel].forEach(addSubview(_:))

        textField.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }

        textCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(textField.snp.trailing)
            make.centerY.equalTo(textField)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                guard let self else { return }

                let pattern = "[^가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]"
                let filteredText = text.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
                let limitedText = String(filteredText.prefix(15))

                if self.textField.text != limitedText {
                    self.textField.text = limitedText
                }

                self.textCountLabel.text = "\(limitedText.count)/15"
                textRelay.accept(limitedText)
            })
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.layer.borderColor = UIColor.appPrimary.cgColor
            })
            .disposed(by: disposeBag)

        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.layer.borderColor = UIColor.systemGray4.cgColor
            })
            .disposed(by: disposeBag)
    }

    func setText(text: String) {
        textField.text = text
        textField.sendActions(for: .editingChanged)
    }
}
