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
    
    private lazy var setNotiRepeatDayOfWeekView = SetNotiRepeatDayOfWeekView(selectedDays: selectedDays)
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
    let selectedDays = BehaviorRelay<Set<DayOfWeek>>(value: [])
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
        
        titleStackView.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
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
    }
}

final class SetNotiTimeView: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .black
        return textField
    }()
    private let timePicker = UIDatePicker()
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
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "ko_KR")
        
        toolbar.items = [doneButton]
        
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
}

final class SetNotiMemoView: UIView {
    private let textFieldContainerView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
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
}

enum DayOfWeekQuickType {
    case everyDay
    case weekdays
    case weekend
}

final class SetNotiRepeatDayOfWeekView: UIView {
    private let everydayButton = TitledButton(
        title: "매일",
        style: .init(
            backgroundColor: nil,
            titleColor: .black,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.7), .red.withAlphaComponent(0.3)]
        )
    )
    private let weekdaysButton = TitledButton(
        title: "평일",
        style: .init(
            backgroundColor: nil,
            titleColor: .black,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.7), .red.withAlphaComponent(0.3)]
        )
    )
    private let weekendButton = TitledButton(
        title: "주말",
        style: .init(
            backgroundColor: nil,
            titleColor: .black,
            borderColor: nil,
            gradientColors: [.red.withAlphaComponent(0.7), .red.withAlphaComponent(0.3)]
        )
    )
    private lazy var selectDayOfWeeksView = SelectDayOfWeeksView(selectedDays: selectedDays)
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.setTitle(" 초기화", for: .normal)
        button.tintColor = .lightGray
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.imageView?.contentMode = .scaleAspectFit

        return button
    }()
    
    let selectedDays: BehaviorRelay<Set<DayOfWeek>>
    let disposeBag = DisposeBag()
    
    init(selectedDays: BehaviorRelay<Set<DayOfWeek>>) {
        self.selectedDays = selectedDays
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let quickTypeStackView = UIStackView(arrangedSubviews: [everydayButton, weekdaysButton, weekendButton])
        quickTypeStackView.axis = .horizontal
        quickTypeStackView.spacing = 8
        quickTypeStackView.distribution = .fillEqually
        
        let mainStackView = UIStackView(arrangedSubviews: [quickTypeStackView, selectDayOfWeeksView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.alignment = .leading
        
        addSubview(mainStackView)
        addSubview(resetButton)
        
        everydayButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        weekdaysButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        weekendButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        resetButton.snp.makeConstraints { make in
            make.top.equalTo(mainStackView.snp.bottom).offset(8)
            make.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setBinding() {
        everydayButton.rx.tap
            .map { Set([.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)
        
        weekdaysButton.rx.tap
            .map { Set([.monday, .tuesday, .wednesday, .thursday, .friday]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)
        
        weekendButton.rx.tap
            .map { Set([.saturday, .sunday]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .map { Set([]) }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)
    }
}

final class SelectDayOfWeeksView: UIView {
    private let dayButtons: [DayOfWeek: SelectableTitledButton] = [
        .monday: SelectableTitledButton(
            title: "월",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        ),
        .tuesday: SelectableTitledButton(
            title: "화",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        ),
        .wednesday: SelectableTitledButton(
            title: "수",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        ),
        .thursday: SelectableTitledButton(
            title: "목",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        ),
        .friday: SelectableTitledButton(
            title: "금",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        ),
        .saturday: SelectableTitledButton(
            title: "토",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        ),
        .sunday: SelectableTitledButton(
            title: "일",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.3),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil,
                selectedBackgroundColor: .systemBlue,
                selectedTitleColor: .white,
                selectedBorderColor: nil,
                selectedGradientColors: nil
            ),
            isCancellable: true
        )
    ]
    
    let selectedDays: BehaviorRelay<Set<DayOfWeek>>
    let disposeBag = DisposeBag()
    
    init(selectedDays: BehaviorRelay<Set<DayOfWeek>>) {
        self.selectedDays = selectedDays
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let orderedDays: [DayOfWeek] = [
            .monday, .tuesday, .wednesday,
            .thursday, .friday, .saturday, .sunday
        ]

        let orderedButtons = orderedDays.compactMap { dayButtons[$0] }

        let mainStackView = UIStackView(arrangedSubviews: orderedButtons)
        mainStackView.axis = .horizontal
        mainStackView.spacing = 8
        mainStackView.distribution = .fillEqually

        addSubview(mainStackView)

        orderedButtons.forEach { button in
            button.snp.makeConstraints { make in
                make.width.height.equalTo(60)
            }
        }

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    
    private func setBinding() {

        for (day, button) in dayButtons {
            button.tapRelay
                .withLatestFrom(selectedDays)
                .subscribe(onNext: { [weak self] current in
                    guard let self else { return }

                    var updated = current

                    if updated.contains(day) {
                        updated.remove(day)
                    } else {
                        updated.insert(day)
                    }

                    self.selectedDays.accept(updated)
                })
                .disposed(by: disposeBag)
        }

        selectedDays
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] days in
                guard let self else { return }

                for (day, button) in self.dayButtons {
                    let shouldSelect = days.contains(day)
                    button.isSelectedRelay.accept(shouldSelect)
                }
            })
            .disposed(by: disposeBag)
    }


}
