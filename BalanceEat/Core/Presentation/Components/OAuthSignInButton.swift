//
//  OAuthSignInButton.swift
//  BalanceEat
//
//  Created by 김견 on 7/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

enum OAuthProvider: String {
    case apple
    case google
    case kakao
}

final class OAuthSignInButton: UIView {
    private let provider: OAuthProvider
    
    private var icon: UIImage {
        switch provider {
        case .apple:
            UIImage(systemName: "apple.logo") ?? UIImage()
        case .google:
            UIImage(named: "GoogleLogo") ?? UIImage()
        case .kakao:
            UIImage(named: "KakaoLogo") ?? UIImage()
        }
    }
    private var color: UIColor {
        switch provider {
        case .apple:
                .appleBackground
        case .google:
                .googleBackground
        case .kakao:
                .kakaoBackground
        }
    }
    private var textColor: UIColor {
        switch provider {
        case .apple:
                .appleText
        case .google:
                .googleText
        case .kakao:
                .kakaoText
        }
    }
    private var titleText: String {
        switch provider {
        case .apple:
            "Apple로"
        case .google:
            "Google로"
        case .kakao:
            "카카오로"
        }
    }
    
    private let tap: PublishSubject<Void> = .init()
    var tapObservable: Observable<Void> {
        return tap.asObservable()
    }
    private let disposeBag = DisposeBag()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()
    
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
    
    init(provider: OAuthProvider) {
        self.provider = provider
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
    }
    
    private func setUpView() {
        self.backgroundColor = color
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
        self.layer.masksToBounds = false
        
        self.layer.borderWidth = provider == .google ? 1 : 0
        self.layer.borderColor = provider == .google ? UIColor(named: "GoogleBorderColor")?.cgColor : UIColor.clear.cgColor
        
        if provider == .apple {
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = textColor
        } else {
            iconImageView.image = icon
        }
        
        titleLabel.text = "\(titleText) 시작하기"
        titleLabel.textColor = textColor
        
        self.addSubview(iconImageView)
        self.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func setUpBinding() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.tap.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
