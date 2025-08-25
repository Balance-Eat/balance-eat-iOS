//
//  TotalNutritionalInfoView.swift
//  BalanceEat
//
//  Created by 김견 on 7/28/25.
//

import UIKit
import SnapKit

final class TotalNutritionalInfoView: UIView {
    private let title: String
    private let foodItems: [AddedFoodItem]
    
    private let contentView = BalanceEatContentView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .totalNutiritionInfoTitle
        return label
    }()
    
    private lazy var calorieInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .calorie, value: foodItems.map { $0.calorie }.reduce(0, +))
    private lazy var carbonInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .carbon, value: foodItems.map { $0.carbon }.reduce(0, +))
    private lazy var proteinInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .protein, value: foodItems.map { $0.protein }.reduce(0, +))
    private lazy var fatInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .fat, value: foodItems.map { $0.fat }.reduce(0, +))
    
    init(title: String, foodItems: [AddedFoodItem]) {
        self.title = title
        self.foodItems = foodItems
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        titleLabel.text = title
        
        self.layer.cornerRadius = 8
        contentView.setBackgroundColor(.totalNutiritionInfoBackground)
        
        self.addSubview(contentView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(calorieInfoView)
        stackView.addArrangedSubview(carbonInfoView)
        stackView.addArrangedSubview(proteinInfoView)
        stackView.addArrangedSubview(fatInfoView)
        
        contentView.addSubview(titleLabel)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(12)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }
    }
}
