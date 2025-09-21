//
//  TitledContainerView.swift
//  BalanceEat
//
//  Created by 김견 on 7/17/25.
//

import UIKit
import SnapKit

final class TitledContainerView: UIView {
    private let icon: UIImage?
    private let title: String
    private lazy var backgroundView: UIView = {
            return isShadowBackground ? BalanceEatContentView() : UIView()
        }()
    private let contentView: UIView
    private let isSmall: Bool
    private let isShadowBackground: Bool
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: isSmall ? 14 : 18, weight: .bold)
        label.textColor = .bodyStatusCardNumber
        return label
    }()
    
    init(icon: UIImage? = nil, title: String, contentView: UIView, isSmall: Bool = false, isShadowBackground: Bool = true) {
        self.icon = icon
        self.title = title
        self.contentView = contentView
        self.isSmall = isSmall
        self.isShadowBackground = isShadowBackground
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(contentView)
        
        iconImageView.isHidden = icon == nil
        
        contentView.isUserInteractionEnabled = true
        
        titleLabel.text = title
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let titleStackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        
        backgroundView.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().offset(-20)
        }
    }
}
