//
//  MenuTipView.swift
//  BalanceEat
//
//  Created by 김견 on 10/26/25.
//

import UIKit
import SnapKit

struct MenuTipData {
    let title: String
    let description: String
}

final class MenuTipView: UIView {
    private let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "info.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    init(title: String, menuTips: [MenuTipData]) {
        super.init(frame: .zero)
        
        self.titleLabel.text = title
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        
        let tipsView = makeTips(menuTips: menuTips)
        
        addSubview(titleStackView)
        addSubview(tipsView)
        
        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(16)
        }
        
        tipsView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeTips(menuTips: [MenuTipData]) -> UIView {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        menuTips.forEach { tip in
            let sectionView = UIView()
            
            let titleLabel = UILabel()
            titleLabel.text = tip.title
            titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
            
            let descriptionLabel = UILabel()
            descriptionLabel.text = tip.description
            descriptionLabel.numberOfLines = 0
            descriptionLabel.font = .systemFont(ofSize: 12)
            
            [titleLabel, descriptionLabel].forEach(sectionView.addSubview(_:))
            
            titleLabel.snp.makeConstraints { make in
                make.top.leading.equalToSuperview()
            }
            descriptionLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.leading.trailing.bottom.equalToSuperview()
            }
            
            mainStackView.addArrangedSubview(sectionView)
        }
        
        return mainStackView
    }
}
