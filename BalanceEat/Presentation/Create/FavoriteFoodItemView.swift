//
//  FavoriteFoodItemView.swift
//  BalanceEat
//
//  Created by 김견 on 7/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FavoriteFoodItemView: UIView {
    private let iconImage: UIImage
    private let name: String
    private let calorie: Int
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .favoriteFoodName
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .favoriteFoodCalorie
        return label
    }()
    
    init(iconImage: UIImage, name: String, calorie: Int) {
        self.iconImage = iconImage
        self.name = name
        self.calorie = calorie
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        iconImageView.image = iconImage
        nameLabel.text = name
        calorieLabel.text = "\(calorie) kcal"
        
        [iconImageView, nameLabel, calorieLabel].forEach {
            addSubview($0)
        }
        
        self.backgroundColor = .favoriteFoodBackground
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.mealTimePickerBorder.cgColor
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        calorieLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
    }
}
