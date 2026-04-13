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
    // 화면 present 시마다 새 DisposeBag으로 교체하여 이전 구독을 해제한다.
    // 교체하지 않으면 이전 인스턴스의 구독이 누적되어 중복 이벤트가 발생한다.
    private var presentationBag = DisposeBag()
    private let dataEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 설정된 알림이 없습니다."
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isHidden = true
        return label
    }()

    private var fetchTask: Task<Void, Never>?
    private var actionTask: Task<Void, Never>?

    override init(viewModel: SetRemindNotiViewModel) {
        super.init(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fetchTask?.cancel()
        actionTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setupTableView()
        setBinding()
        getDatas(page: 0, size: 10)
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

        tableView.addSubview(dataEmptyLabel)

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
        button.accessibilityLabel = "알림 추가"
        button.accessibilityHint = "새 반복 알림을 추가합니다"
        navigationItem.rightBarButtonItem = button
    }

    private func setupTableView() {
        tableView.register(RemindNotificationCell.self, forCellReuseIdentifier: "RemindNotificationCell")
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
            .bind(to: tableView.rx.items(cellIdentifier: "RemindNotificationCell", cellType: RemindNotificationCell.self)) { index, model, cell in

                cell.remindView.configure(model)

                cell.remindView.editButtonTapRelay
                    .subscribe(onNext: { [weak self] in
                        guard let self else { return }
                        presentEditNotiViewController(editNotiCase: .edit, reminderData: model) { [weak self] data in
                            self?.actionTask = Task {
                                await self?.viewModel.updateReminder(reminderDataForCreate: data, reminderId: model.id)
                            }
                        }
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
                        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                            self?.actionTask = Task {
                                await self?.viewModel.deleteReminder(reminderId: model.id)
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
                        self.actionTask = Task {
                            await self.viewModel.updateReminderActivation(isActive: isOn, reminderId: model.id)
                        }
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] offset in
                guard let self else { return }
                let threshold = self.tableView.contentSize.height - self.tableView.frame.size.height
                if offset.y > threshold && !self.viewModel.isLastPage && self.viewModel.isLoadingNextPageRelay.value == false {
                    self.fetchTask = Task {
                        await self.viewModel.fetchReminderList()
                    }
                }
            })
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                getDatas(page: 0, size: 100)
            }
            .disposed(by: disposeBag)

        viewModel.successToSaveReminderRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                getDatas(page: 0, size: 100)
            })
            .disposed(by: disposeBag)
    }

    private func getDatas(page: Int, size: Int) {
        fetchTask = Task {
            await viewModel.getReminderList(page: page, size: size)
            refreshControl.endRefreshing()
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapPlus() {
        presentEditNotiViewController(editNotiCase: .add) { [weak self] data in
            self?.actionTask = Task {
                await self?.viewModel.createReminder(reminderDataForCreate: data)
            }
        }
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

    private static let hhMmFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:00"
        return formatter
    }()

    private func timeStringHHmm00(from date: Date) -> String {
        SetRemindNotiViewController.hhMmFormatter.string(from: date)
    }

    private func presentEditNotiViewController(
        editNotiCase: EditNotiCase,
        reminderData: ReminderData? = nil,
        onSave: @escaping (ReminderDataForCreate) -> Void
    ) {
        presentationBag = DisposeBag()

        let editNotiViewController = EditNotiViewController(editNotiCase: editNotiCase)
        editNotiViewController.modalPresentationStyle = .overCurrentContext
        editNotiViewController.modalTransitionStyle = .crossDissolve

        if let reminderData {
            editNotiViewController.setDatas(reminderData: reminderData)
        }

        viewModel.successToSaveReminderRelay
            .bind(to: editNotiViewController.successToSaveRelay)
            .disposed(by: presentationBag)

        editNotiViewController.saveButtonTapRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                let data = ReminderDataForCreate(
                    content: editNotiViewController.memoRelay.value,
                    sendTime: timeStringHHmm00(from: editNotiViewController.timeRelay.value),
                    isActive: true,
                    dayOfWeeks: editNotiViewController.selectedDaysRelay.value.map { $0.rawValue }
                )
                onSave(data)
            })
            .disposed(by: presentationBag)

        present(editNotiViewController, animated: true)
    }
}
