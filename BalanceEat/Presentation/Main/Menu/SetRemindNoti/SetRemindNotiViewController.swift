//
//  SetRemindNotiViewController.swift
//  BalanceEat
//
//  Created by 김견 on 11/30/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SetRemindNotiViewController: BaseViewController<SetRemindNotiViewModel> {
    
    private var bottomConstraint: Constraint?
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let dataEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 설정된 알림이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isHidden = true
        return label
    }()
    
    init() {
        let notificationRepository = NotificationRepository()
        let notificationUseCase = NotificationUseCase(repository: notificationRepository)
        let reminderRepository = ReminderRepository()
        let reminderUseCase = ReminderUseCase(repository: reminderRepository)
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        let vm = SetRemindNotiViewModel(notificationUseCase: notificationUseCase, reminderUseCase: reminderUseCase, userUseCase: userUseCase)
        
        super.init(viewModel: vm)
        
        setBinding()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setupTableView()
        getDatas()
        setUpKeyboardDismissGesture()
        observeKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setUpView() {
        topContentView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        scrollView.snp.makeConstraints { make in
            self.bottomConstraint = make.bottom.equalToSuperview().inset(0).constraint
        }
        
        view.addSubview(dataEmptyLabel)
        
        dataEmptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        navigationItem.title = "추가 알림 설정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        let button = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapPlus)
        )

        button.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupTableView() {
        tableView.register(RemindNotificationCell.self,
                           forCellReuseIdentifier: "RemindNotificationCell")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = .clear

        view.addSubview(tableView)
        view.bringSubviewToFront(loadingView)
        
        loadingView.snp.remakeConstraints { make in
            make.center.equalTo(tableView)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func setBinding() {
        viewModel.reminderListRelay
            .map { $0.count > 0 }
            .bind(to: dataEmptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.reminderListRelay
            .observe(on: MainScheduler.instance)
            .bind(
                to: tableView.rx.items(
                    cellIdentifier: "RemindNotificationCell",
                    cellType: RemindNotificationCell.self
                )
            ) { index, model, cell in
            
                cell.remindView.configure(model)
                
                cell.remindView.editButtonTapRelay
                    .subscribe(onNext: { [weak self] in
                        guard let self else { return }
                        
                        let editNotiViewController = EditNotiViewController(editNotiCase: .edit)
                        editNotiViewController.modalPresentationStyle = .overCurrentContext
                        editNotiViewController.modalTransitionStyle = .crossDissolve
                        editNotiViewController.setDatas(reminderData: model)
                        
                        viewModel.successToSaveReminderRelay
                            .bind(to: editNotiViewController.successToSaveRelay)
                            .disposed(by: disposeBag)
                        
                        editNotiViewController.saveButtonTapRelay
                            .observe(on: MainScheduler.instance)
                            .subscribe(
                                onNext: { [weak self] in
                                    guard let self else { return }
                                    
                                    let content = editNotiViewController.memoRelay.value
                                    let sendTime = timeStringHHmm00(from: editNotiViewController.timeRelay.value)
                                    let dayOfWeeks = editNotiViewController.selectedDaysRelay.value.map { $0.rawValue }
                                    
                                    let reminderDataForCreate = ReminderDataForCreate(
                                        content: content,
                                        sendTime: sendTime,
                                        isActive: true,
                                        dayOfWeeks: dayOfWeeks
                                    )
                                
                                Task {
                                    await self.viewModel.updateReminder(reminderDataForCreate: reminderDataForCreate, reminderId: model.id)
                                }
                            })
                            .disposed(by: disposeBag)
                        
                        present(editNotiViewController, animated: true, completion: nil)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.remindView.deleteButtonTapRelay
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] in
                        guard let self else { return }
                        
                        let alert = UIAlertController(
                            title: "해당 알림을 삭제하시겠습니까?",
                            message: "되돌릴 수 없습니다.",
                            preferredStyle: .alert
                        )
                        
                        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                        
                        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                            Task {
                                await self.viewModel.deleteReminder(reminderId: model.id)
                            }
                        })
                        
                        self.present(alert, animated: true)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.remindView.isSwitchOnRelay
                    .skip(1)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] isOn in
                        guard let self else { return }
                        
                        Task {
                            await self.viewModel.updateReminderActivation(isActive: isOn, reminderId: model.id)
                        }
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] offset in
                guard let self = self else { return }
                let threshold = self.tableView.contentSize.height - self.tableView.frame.size.height
                if offset.y > threshold && !self.viewModel.isLastPage && self.viewModel.isLoadingNextPageRelay.value == false {
                    Task {
                        await self.viewModel.fetchReminderList()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                
                getDatas()
            }
            .disposed(by: disposeBag)
    }
    
    private func getDatas() {
        Task {
            await viewModel.getReminderList()
            
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc private func didTapPlus() {
        let editNotiViewController = EditNotiViewController(editNotiCase: .add)
        editNotiViewController.modalPresentationStyle = .overCurrentContext
        editNotiViewController.modalTransitionStyle = .crossDissolve
        
        viewModel.successToSaveReminderRelay
            .bind(to: editNotiViewController.successToSaveRelay)
            .disposed(by: disposeBag)
        
        editNotiViewController.saveButtonTapRelay
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] in
                    guard let self else { return }
                    
                    let content = editNotiViewController.memoRelay.value
                    let sendTime = timeStringHHmm00(from: editNotiViewController.timeRelay.value)
                    let dayOfWeeks = editNotiViewController.selectedDaysRelay.value.map { $0.rawValue }
                    
                    let reminderDataForCreate = ReminderDataForCreate(
                        content: content,
                        sendTime: sendTime,
                        isActive: true,
                        dayOfWeeks: dayOfWeeks
                    )
                
                Task {
                    await self.viewModel.createReminder(reminderDataForCreate: reminderDataForCreate)
                }
            })
            .disposed(by: disposeBag)
        
        present(editNotiViewController, animated: true, completion: nil)
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = frame.height
        
        bottomConstraint?.update(inset: keyboardHeight)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        bottomConstraint?.update(inset: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func timeStringHHmm00(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:00"
        return formatter.string(from: date)
    }
}

final class RemindNotificationCell: UITableViewCell {
    
    let remindView = RemindNotificationView()
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(remindView)
        
        remindView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.6)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 8
        return view
    }()
    
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
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        
        imageContainerView.addSubview(timeImageView)
        
        let dayStackView = UIStackView(arrangedSubviews: [dayImageView, dayLabel])
        dayStackView.axis = .horizontal
        dayStackView.spacing = 4
        
        dayImageView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
        
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
        
        timeImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        addSubview(mainVerticalStackView)
        addSubview(overlayView)
        
        mainVerticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.width.height.equalTo(48)
        }
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.layer.cornerRadius = 24
        imageContainerView.clipsToBounds = true
    }
    
    private func setBinding() {
        toggleSwitch.rx.isOn
            .bind(to: isSwitchOnRelay)
            .disposed(by: disposeBag)
        
        isSwitchOnRelay
            .bind(to: overlayView.rx.isHidden)
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
        overlayView.isHidden = reminderData.isActive
    }
    
    private func getDayString(dayOfWeeks: [String]) -> String {
        let inputSet = Set(dayOfWeeks)

        let allDays: Set<String> = [
            DayOfWeek.monday.rawValue,
            DayOfWeek.tuesday.rawValue,
            DayOfWeek.wednesday.rawValue,
            DayOfWeek.thursday.rawValue,
            DayOfWeek.friday.rawValue,
            DayOfWeek.saturday.rawValue,
            DayOfWeek.sunday.rawValue
        ]

        let weekdays: Set<String> = [
            DayOfWeek.monday.rawValue,
            DayOfWeek.tuesday.rawValue,
            DayOfWeek.wednesday.rawValue,
            DayOfWeek.thursday.rawValue,
            DayOfWeek.friday.rawValue
        ]

        let weekend: Set<String> = [
            DayOfWeek.saturday.rawValue,
            DayOfWeek.sunday.rawValue
        ]

        let order: [DayOfWeek] = [
            .monday, .tuesday, .wednesday,
            .thursday, .friday, .saturday, .sunday
        ]

        if inputSet == allDays {
            return "매일"
        } else if inputSet == weekdays {
            return "평일"
        } else if inputSet == weekend {
            return "주말"
        } else {
            return order
                .filter { inputSet.contains($0.rawValue) }
                .map { $0.koreanValue }
                .joined(separator: ", ")
        }
    }


}
