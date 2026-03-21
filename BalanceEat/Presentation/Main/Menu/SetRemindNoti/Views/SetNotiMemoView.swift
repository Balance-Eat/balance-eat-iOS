//
//  SetNotiMemoView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SetNotiMemoView: UIView {
    private let textFieldContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.appBorder.withAlphaComponent(0.3).cgColor
        view.layer.borderWidth = 1
        return view
    }()
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .black
        textField.autocapitalizationType = .none
        return textField
    }()
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
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
        textFieldContainerView.addSubview(textField)
        [textFieldContainerView, textCountLabel].forEach(addSubview(_:))

        textFieldContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        textCountLabel.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainerView.snp.bottom).offset(8)
            make.trailing.bottom.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        textField.rx.text.orEmpty
            .bind(to: textRelay)
            .disposed(by: disposeBag)

        textField.rx.text.orEmpty
            .map { [weak self] text -> String in
                guard let self else { return "" }

                let limitedText = String(text.prefix(50))
                self.textCountLabel.text = "\(limitedText.count)/50"
                return limitedText
            }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }

    func setMemo(memo: String) {
        textField.text = memo
        textField.sendActions(for: .editingChanged)
    }
}
