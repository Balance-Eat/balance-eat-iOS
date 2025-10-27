//
//  MenuViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MenuViewController: BaseViewController<MenuViewModel> {
    private let profileInfoView = ProfileInfoView(name: "", goal: "", currentWeight: 0, goalWeight: 0)
    private let basicInfoMenuItemView = MenuItemView(
        icon: UIImage(systemName: "person.fill") ?? UIImage(),
        iconTintColor: .systemBlue,
        iconBackgroundColor: .systemBlue.withAlphaComponent(0.15),
        title: "기본 정보 수정",
        subtitle: "이름, 성별, 나이 키 변경"
    )
    private let editTargetMenuItemView = MenuItemView(
        icon: UIImage(systemName: "person.crop.circle") ?? UIImage(),
        iconTintColor: .systemGreen,
        iconBackgroundColor: .systemGreen.withAlphaComponent(0.15),
        title: "목표 수치 편집",
        subtitle: "체중, 골격근량, 체지방률 목표 조정"
    )
    private let targetTypeAndActivityLevelMenuItemView = MenuItemView(
        icon: UIImage(systemName: "flame.fill") ?? UIImage(),
        iconTintColor: .red,
        iconBackgroundColor: .red.withAlphaComponent(0.15),
        title: "활동량 설정",
        subtitle: "일상 활동량 조정"
    )
    
    init() {
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        let vm = MenuViewModel(userUseCase: userUseCase)
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getDatas()
    }
    
    private func setUpView() {
        topContentView.addSubview(profileInfoView)
        profileInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        let personalInfoMenuStackView = createMenuStackView(title: "개인 정보", views: [
            basicInfoMenuItemView,
            editTargetMenuItemView,
            targetTypeAndActivityLevelMenuItemView
        ])
        
        [personalInfoMenuStackView].forEach(mainStackView.addArrangedSubview)
        
        
    }
    
    private func setBinding() {
        viewModel.userRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let self else { return }
                self.updateUIForUserData(user: user)
            })
            .disposed(by: disposeBag)
        
        basicInfoMenuItemView.onTap = { [weak self] in
            guard let self else { return }
            guard let userData = viewModel.userRelay.value else { return }
            
            navigationController?.pushViewController(EditBasicInfoViewController(userData: userData), animated: true)
        }
        
        editTargetMenuItemView.onTap = { [weak self] in
            guard let self else { return }
            guard let userData = viewModel.userRelay.value else { return }
            
            navigationController?.pushViewController(EditTargetViewController(userData: userData), animated: true)
        }
        
        targetTypeAndActivityLevelMenuItemView.onTap = { [weak self] in
            guard let self else { return }
            guard let userData = viewModel.userRelay.value else { return }
            
            navigationController?.pushViewController(EditTargetTypeAndActivityLevelViewController(userData: userData), animated: true)
        }
    }
    
    private func getDatas() {
        Task {
            await viewModel.getUser()
        }
    }
    
    private func updateUIForUserData(user: UserData) {
        profileInfoView.updateView(name: user.name, goal: "다이어트", currentWeight: user.weight, targetWeight: user.targetWeight)
    }
    
    private func createMenuStackView(title: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .gray
        titleLabel.text = title
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        views.forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }
}

final class ProfileInfoView: UIView {
    private let name: String
    private let goal: String
    private let currentWeight: Double
    private let targetWeight: Double
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let goalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let targetWeightDiffLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, goalLabel, targetWeightDiffLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [profileImageView, textStack])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    init(name: String, goal: String, currentWeight: Double, goalWeight: Double) {
        self.name = name
        self.goal = goal
        self.currentWeight = currentWeight
        self.targetWeight = goalWeight
        super.init(frame: .zero)
        setupGradient()
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.withAlphaComponent(0.5).cgColor, UIColor.systemPurple.withAlphaComponent(0.5).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func setUpView() {
        nameLabel.text = name
        goalLabel.text = goal
        targetWeightDiffLabel.text = "\(String(format: "%.1f", currentWeight))kg → \(String(format: "%.1f", targetWeight))kg"
        
        addSubview(mainStack)
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        mainStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(32)
        }
    }
    
    func updateView(name: String, goal: String, currentWeight: Double, targetWeight: Double) {
        nameLabel.text = name
        goalLabel.text = goal
        targetWeightDiffLabel.text = "\(String(format: "%.1f", currentWeight))kg → \(String(format: "%.1f", targetWeight))kg"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds
    }
}

final class MenuItemView: UIView {
    private let icon: UIImage
    private let iconTintColor: UIColor
    private let iconBackgroundColor: UIColor
    private let title: String
    private let subtitle: String
    
    private let iconContentView = UIView()
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = icon
        return imageView
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.text = title
        return label
    }()
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .label
        label.text = subtitle
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconContentView, textStack])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    let disposeBag = DisposeBag()
    var onTap: (() -> Void)?
    
    init(icon: UIImage, iconTintColor: UIColor, iconBackgroundColor: UIColor, title: String, subtitle: String) {
        self.icon = icon
        self.iconTintColor = iconTintColor
        self.iconBackgroundColor = iconBackgroundColor
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.alpha = 0.6
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.alpha = 1.0
    }
    
    private func setUpView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        iconContentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.width.height.equalTo(20)
        }
        
        addSubview(mainStack)
        
        iconContentView.backgroundColor = iconBackgroundColor
        iconContentView.layer.cornerRadius = 8
        
        iconImageView.tintColor = iconTintColor
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .secondaryLabel
        
        addSubview(arrowImageView)
        
        mainStack.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setBinding() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(onNext: { [weak self] _ in
                self?.onTap?()
            })
            .disposed(by: disposeBag)
    }
}
