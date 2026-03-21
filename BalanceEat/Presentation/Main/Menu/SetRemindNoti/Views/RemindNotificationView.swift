//
//  RemindNotificationView.swift
//  BalanceEat
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class RemindNotificationView: UIView {
    private let timeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "timer")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        return view
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let dayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = .gray
        return imageView
    }()
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.isOn = true
        toggleSwitch.onTintColor = .systemBlue
        return toggleSwitch
    }()
    private let editButton = TitledButton(
        title: "수정",
        image: UIImage(systemName: "pencil"),
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.15),
            titleColor: .black,
            borderColor: nil,
            gradientColors: nil
        )
    )
    private let deleteButton = TitledButton(
        title: "삭제",
        image: UIImage(systemName: "trash"),
        style: .init(
            backgroundColor: .systemRed.withAlphaComponent(0.15),
            titleColor: .systemRed,
            borderColor: nil,
            gradientColors: nil
        )
    )

    let editButtonTapRelay: PublishRelay<Void> = .init()
    let deleteButtonTapRelay: PublishRelay<Void> = .init()
    let isSwitchOnRelay: BehaviorRelay<Bool> = .init(value: true)
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
        timeLabel.text = "07:30"
        contentLabel.text = "아침 식사"
        dayLabel.text = "금요일"

        self.backgroundColor = .white
        self.layer.borderColor = UIColor.appBorder.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8

        imageContainerView.addSubview(timeImageView)

        let dayStackView = UIStackView(arrangedSubviews: [dayImageView, dayLabel])
        dayStackView.axis = .horizontal
        dayStackView.spacing = 4

        dayImageView.snp.makeConstraints { make in make.width.height.equalTo(14) }

        let infoStackView = UIStackView(arrangedSubviews: [timeLabel, contentLabel, dayStackView])
        infoStackView.axis = .vertical
        infoStackView.spacing = 8

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let mainHorizontalStackView = UIStackView(arrangedSubviews: [imageContainerView, infoStackView, spacer, toggleSwitch])
        mainHorizontalStackView.axis = .horizontal
        mainHorizontalStackView.spacing = 12
        mainHorizontalStackView.alignment = .center

        let buttonStackView = UIStackView(arrangedSubviews: [editButton, deleteButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8

        let mainVerticalStackView = UIStackView(arrangedSubviews: [mainHorizontalStackView, buttonStackView])
        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.spacing = 12

        timeImageView.snp.makeConstraints { make in make.edges.equalToSuperview().inset(12) }

        addSubview(mainVerticalStackView)

        mainVerticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        imageContainerView.snp.makeConstraints { make in make.width.height.equalTo(48) }
        imageContainerView.layer.cornerRadius = 24
        imageContainerView.clipsToBounds = true
    }

    private func setBinding() {
        toggleSwitch.rx.isOn
            .bind(to: isSwitchOnRelay)
            .disposed(by: disposeBag)

        isSwitchOnRelay
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                setUIBySwitchState(isOn: isOn)
            })
            .disposed(by: disposeBag)

        editButton.rx.tap
            .bind(to: editButtonTapRelay)
            .disposed(by: disposeBag)

        deleteButton.rx.tap
            .bind(to: deleteButtonTapRelay)
            .disposed(by: disposeBag)
    }

    func configure(_ reminderData: ReminderData) {
        timeLabel.text = String(reminderData.sendTime.prefix(5))
        contentLabel.text = reminderData.content
        dayLabel.text = getDayString(dayOfWeeks: reminderData.dayOfWeeks)
        toggleSwitch.isOn = reminderData.isActive
        setUIBySwitchState(isOn: reminderData.isActive)
    }

    private func getDayString(dayOfWeeks: [String]) -> String {
        let inputSet = Set(dayOfWeeks.compactMap { DayOfWeek(rawValue: $0) })

        let allDays: Set<DayOfWeek> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let weekdays: Set<DayOfWeek> = [.monday, .tuesday, .wednesday, .thursday, .friday]
        let weekend: Set<DayOfWeek> = [.saturday, .sunday]

        if inputSet == allDays { return "매일" }
        if inputSet == weekdays { return "평일" }
        if inputSet == weekend { return "주말" }

        return [DayOfWeek.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
            .filter { inputSet.contains($0) }
            .map { $0.koreanValue }
            .joined(separator: ", ")
    }

    private func setUIBySwitchState(isOn: Bool) {
        timeImageView.tintColor = isOn ? .systemBlue : .systemBlue.withAlphaComponent(0.3)
        imageContainerView.backgroundColor = isOn ? .systemBlue.withAlphaComponent(0.2) : .systemBlue.withAlphaComponent(0.05)
        timeLabel.textColor = isOn ? .black : .lightGray
        contentLabel.textColor = isOn ? .black : .lightGray
    }
}
