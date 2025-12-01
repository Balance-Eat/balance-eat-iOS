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
    
    private let remindNotificationView = RemindNotificationView()
    
    init() {
        let notificationRepository = NotificationRepository()
        let notificationUseCase = NotificationUseCase(repository: notificationRepository)
        let vm = SetRemindNotiViewModel(notificationUseCase: notificationUseCase)
        
        super.init(viewModel: vm)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
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
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints { make in
            self.bottomConstraint = make.bottom.equalToSuperview().inset(0).constraint
        }
        
        [remindNotificationView].forEach(mainStackView.addArrangedSubview(_:))
        
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
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc private func didTapPlus() {
        
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
        view.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        return view
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let memoLabel: UILabel = {
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
        memoLabel.text = "아침 식사"
        dayLabel.text = "금요일"
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        
        imageContainerView.addSubview(timeImageView)
        
        let dayStackView = UIStackView(arrangedSubviews: [dayImageView, dayLabel])
        dayStackView.axis = .horizontal
        dayStackView.spacing = 4
        
        let infoStackView = UIStackView(arrangedSubviews: [timeLabel, memoLabel, dayStackView])
        infoStackView.axis = .vertical
        infoStackView.spacing = 4
        
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
    }
}
