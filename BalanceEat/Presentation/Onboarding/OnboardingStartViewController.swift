//
//  OnboardingStartViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/6/25.
//

import UIKit
import SnapKit

class OnboardingStartViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    private let logoImageVIew: UIImageView = {
        let imageView = UIImageView(image: .balanceEatLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "스마트한 식단 관리의 시작"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "다이어트부터 벌크업까지, 당신의 목표를 달성해보세요!"
        return label
    }()
    
    private let gradientBackgroundView: GradientView = {
        let view = GradientView()
        view.colors = [.proteinTimeCardStartBackground, .proteinTimeCardEndBackground]
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("시작하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = .clear
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setUpView()
        setUpEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        
        gradientBackgroundView.addSubview(startButton)
        
        let descriptions = ["정확한 칼로리 및 영양소 추적", "개인별 맞춤 통계 및 분석", "스마트 알림으로 규칙적인 식사"]
        
        [logoImageVIew, titleLabel, subtitleLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        let firstIconAndTitleHorizontalView = IconAndTitleHorizontalView(
            iconImage: UIImage(systemName: "checkmark.circle") ?? UIImage(),
            title: "정확한 칼로리 및 영양소 추적",
            iconColor: .startFirstDescriptionIcon,
            allBackgroundColor: .startFirstDescriptionBackground,
            borderColor: .startFirstDescriptionBorder
        )
        
        let secondIconAndTitleHorizontalView = IconAndTitleHorizontalView(
            iconImage: UIImage(systemName: "chart.bar") ?? UIImage(),
            title: "개인별 맞춤 통계 및 분석",
            iconColor: .startSecondDescriptionIcon,
            allBackgroundColor: .startSecondDescriptionBackground,
            borderColor: .startSecondDescriptionBorder
        )
        
        let thirdIconAndTitleHorizontalView = IconAndTitleHorizontalView(
            iconImage: UIImage(systemName: "clock") ?? UIImage(),
            title: "스마트 알림으로 규칙적인 식사",
            iconColor: .startThirdDescriptionIcon,
            allBackgroundColor: .startThirdDescriptionBackground,
            borderColor: .startThirdDescriptionBorder
        )
        
        [firstIconAndTitleHorizontalView, secondIconAndTitleHorizontalView, thirdIconAndTitleHorizontalView].forEach {
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints { make in
                make.height.equalTo(44)
                make.width.equalToSuperview()
            }
        }
        
        stackView.addArrangedSubview(gradientBackgroundView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        
        logoImageVIew.snp.makeConstraints { make in
            make.width.height.equalTo(240)
        }
        
        gradientBackgroundView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalToSuperview()
        }
        
        startButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.setCustomSpacing(-40, after: logoImageVIew)
        stackView.setCustomSpacing(12, after: titleLabel)
        stackView.setCustomSpacing(40, after: subtitleLabel)
        stackView.setCustomSpacing(40, after: thirdIconAndTitleHorizontalView)
    }
    
    private func setUpEvent() {
        startButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        startButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
    }
    
    @objc private func buttonTouchDown() {
        gradientBackgroundView.alpha = 0.7
    }
    
    @objc private func buttonTouchUp() {
        gradientBackgroundView.alpha = 1.0
    }
}

final class IconAndTitleHorizontalView: UIView {
    private let iconImage: UIImage
    private let title: String
    private let iconColor: UIColor
    private let allBackgroundColor: UIColor
    private let borderColor: UIColor
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    init(iconImage: UIImage, title: String, iconColor: UIColor, allBackgroundColor: UIColor, borderColor: UIColor) {
        self.iconImage = iconImage
        self.title = title
        self.iconColor = iconColor
        self.allBackgroundColor = allBackgroundColor
        self.borderColor = borderColor
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        iconImageView.image = iconImage
        iconImageView.tintColor = iconColor
        
        titleLabel.text = title
        
        self.addSubview(iconImageView)
        self.addSubview(titleLabel)
        
        self.backgroundColor = allBackgroundColor
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
    }
}
