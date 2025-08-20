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

class MenuViewController: UIViewController {
    private let profileInfoView = ProfileInfoView()
    private let editTargetMenuItemView = MenuItemView(
        icon: UIImage(systemName: "person.crop.circle") ?? UIImage(),
        iconTintColor: .systemBlue,
        iconBackgroundColor: .systemBlue.withAlphaComponent(0.15),
        title: "목표 수치 편집",
        subtitle: "체중, 골격근량, 체지방률 목표 조정"
    )
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUpView() {
        view.backgroundColor = .homeScreenBackground
        view.addSubview(profileInfoView)
        view.addSubview(editTargetMenuItemView)
        
        profileInfoView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
        
        editTargetMenuItemView.snp.makeConstraints { make in
            make.top.equalTo(profileInfoView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        editTargetMenuItemView.onTap = {
            self.navigationController?.pushViewController(EditTargetViewController(), animated: true)
        }
    }
}

final class ProfileInfoView: UIView {
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "진문짱"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "다이어트 🔥"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let goalLabel: UILabel = {
        let label = UILabel()
        label.text = "⚖️ 70kg → 65kg"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, subTitleLabel, goalLabel])
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
    
    init() {
        super.init(frame: .zero)
        setupGradient()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
        setupLayout()
    }
    
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.withAlphaComponent(0.5).cgColor, UIColor.systemPurple.withAlphaComponent(0.5).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupLayout() {
        addSubview(mainStack)
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        mainStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(32)
        }
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
