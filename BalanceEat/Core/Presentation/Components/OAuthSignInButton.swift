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

final class OAuthSignInButton: UIView {
    private let icon: UIImage
    private let name: String
    private let color: UIColor
    private let textColor: UIColor
    
    private let tap: PublishSubject<Void> = .init()
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
    
    init(icon: UIImage, name: String, color: UIColor, textColor: UIColor) {
        self.icon = icon
        self.name = name
        self.color = color
        self.textColor = textColor
        super.init(frame: .zero)
        
        setUpView()
        setUpBinding()
    }
    
    private func setUpView() {
        self.backgroundColor = color
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        iconImageView.image = icon
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        titleLabel.text = "\(name)으로 시작하기"
        titleLabel.textColor = textColor
        
        containerView.addArrangedSubview(iconImageView)
        containerView.addArrangedSubview(titleLabel)
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
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
