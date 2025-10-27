//
//  EditDataContentView.swift
//  BalanceEat
//
//  Created by 김견 on 10/23/25.
//

import UIKit

final class EditDataContentView: BalanceEatContentView {
    private let titleIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    private let imageBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let subView: UIView
    
    init(systemImageString: String, imageBackgroundColor: UIColor, titleText: String, subtitleText: String, subView: UIView) {
        self.subView = subView
        super.init()
        
        setUpView(systemImageString: systemImageString, imageBackgroundColor: imageBackgroundColor, titleText: titleText, subtitleText: subtitleText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(systemImageString: String, imageBackgroundColor: UIColor, titleText: String, subtitleText: String) {
        let mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [])
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()
        titleIconImageView.image = UIImage(systemName: systemImageString)
        
        imageBackgroundView.backgroundColor = imageBackgroundColor
        imageBackgroundView.clipsToBounds = true
        imageBackgroundView.addSubview(titleIconImageView)
        
        titleIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.edges.equalToSuperview().inset(10)
        }
        
        titleLabel.text = titleText
        
        subtitleLabel.text = subtitleText
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let labelStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        
        let titleStackView = UIStackView(arrangedSubviews: [imageBackgroundView, labelStackView])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 12
        
        
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(subView)
        
        addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}
