//
//  EditNotiViewController.swift
//  BalanceEat
//
//  Created by 김견 on 12/1/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum EditNotiCase {
    case add
    case edit
}

final class EditNotiViewController: UIViewController {
    private var bottomConstraint: Constraint?
    private let editNotiCase: EditNotiCase
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        return button
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    private let setNotiTimeView = SetNotiTimeView()
    private lazy var notiTimeTitledInputInfoView = TitledInputInfoView(title: "알림 시간 *", inputView: setNotiTimeView, useBalanceEatWrapper: false)

    private let setNotiMemoView = SetNotiMemoView()
    private lazy var notiMemoTitledInputInfoView = TitledInputInfoView(title: "메모 *", inputView: setNotiMemoView, useBalanceEatWrapper: false)

    private lazy var setNotiRepeatDayOfWeekView = SetNotiRepeatDayOfWeekView(selectedDays: selectedDaysRelay)
    private lazy var notiRepeatDayOfWeekTitledInputInfoView = TitledInputInfoView(title: "반복 요일 *", inputView: setNotiRepeatDayOfWeekView, useBalanceEatWrapper: false)

    private lazy var saveButton = TitledButton(
        title: editNotiCase == .add ? "알림 추가" : "수정 완료",
        image: UIImage(systemName: "square.and.arrow.down"),
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.5)]
        )
    )
    private let cancelButton = TitledButton(
        title: "취소",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.1),
            titleColor: .black,
            borderColor: nil,
            gradientColors: nil
        )
    )

    let timeRelay = BehaviorRelay<Date>(value: Date())
    let memoRelay = BehaviorRelay<String>(value: "")
    let selectedDaysRelay = BehaviorRelay<Set<DayOfWeek>>(value: [])
    let isValidInputRelay: BehaviorRelay<Bool> = .init(value: false)

    let saveButtonTapRelay = PublishRelay<Void>()
    let successToSaveRelay: PublishRelay<Void> = .init()
    private let disposeBag = DisposeBag()

    init(editNotiCase: EditNotiCase) {
        self.editNotiCase = editNotiCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setBinding()
        setUpKeyboardDismissGesture()
        observeKeyboard()
    }

    private func setUpView() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 8

        switch editNotiCase {
        case .add:
            titleLabel.text = "새 알림 추가"
        case .edit:
            titleLabel.text = "알림 수정"
        }

        let contentView = BalanceEatContentView()

        view.addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }

        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, exitButton])
        titleStackView.axis = .horizontal
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .center
        titleStackView.spacing = 0

        titleStackView.snp.makeConstraints { make in make.height.equalTo(32) }
        saveButton.snp.makeConstraints { make in make.height.equalTo(44) }
        cancelButton.snp.makeConstraints { make in make.height.equalTo(44) }

        [titleStackView, notiTimeTitledInputInfoView, notiMemoTitledInputInfoView, notiRepeatDayOfWeekTitledInputInfoView, saveButton, cancelButton].forEach(mainStackView.addArrangedSubview(_:))
    }

    private func setBinding() {
        setNotiTimeView.timeRelay
            .bind(to: timeRelay)
            .disposed(by: disposeBag)

        setNotiMemoView.textRelay
            .bind(to: memoRelay)
            .disposed(by: disposeBag)

        exitButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .bind(to: saveButtonTapRelay)
            .disposed(by: disposeBag)

        successToSaveRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(memoRelay, selectedDaysRelay) { memo, selectedDays -> Bool in
            !memo.isEmpty && !selectedDays.isEmpty
        }
        .bind(to: isValidInputRelay)
        .disposed(by: disposeBag)

        isValidInputRelay
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    func setDatas(reminderData: ReminderData) {
        setNotiTimeView.setTime(date: timeStringToDate(reminderData.sendTime) ?? Date())
        setNotiMemoView.setMemo(memo: reminderData.content)
        let dayOfWeeksSet = Set(reminderData.dayOfWeeks.compactMap { DayOfWeek(rawValue: $0) })
        selectedDaysRelay.accept(dayOfWeeksSet)
    }

    private func setUpKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        bottomConstraint?.update(inset: frame.height)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.update(inset: 0)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    private func timeStringToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: time)
    }
}
