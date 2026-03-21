//
//  SetNotiTimeView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SetNotiTimeView: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .black
        return textField
    }()
    private let timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.minuteInterval = 5
        return timePicker
    }()
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    private let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)

    let timeRelay = BehaviorRelay<Date>(value: Date())
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
        self.layer.borderColor = UIColor.appBorder.withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8

        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "ko_KR")

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]

        textField.inputView = timePicker
        textField.inputAccessoryView = toolbar

        addSubview(textField)

        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }

    private func setBinding() {
        let formatter = DateFormatter()
        formatter.dateFormat = "a hh:mm"
        formatter.locale = Locale(identifier: "ko_KR")

        timePicker.rx.date
            .bind(to: timeRelay)
            .disposed(by: disposeBag)

        timePicker.rx.date
            .map { formatter.string(from: $0) }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)

        doneButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                textField.resignFirstResponder()
            }
            .disposed(by: disposeBag)
    }

    func setTime(date: Date) {
        timePicker.date = date
        timePicker.sendActions(for: .editingChanged)
    }
}
