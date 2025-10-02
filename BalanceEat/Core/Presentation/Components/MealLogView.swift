//
//  MealLogView.swift
//  BalanceEat
//
//  Created by 김견 on 7/15/25.
//

import UIKit
import SnapKit

final class MealLogView: UIView {
    private let icon: UIImage?
    private let title: String
    private let ateTime: String
    private let consumedCalories: Int
    private let foodDatas: [DietFoodData]
    private let showNutritionInfo: Bool
    
    private let containerView: UIView = BalanceEatContentView()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemOrange
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private let ateTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let consumedCaloriesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        return label
    }()
    
    init(icon: UIImage? = nil, title: String, ateTime: String, consumedCalories: Int, foodDatas: [DietFoodData], showNutritionInfo: Bool = false) {
        self.icon = icon
        self.title = title
        self.ateTime = ateTime
        self.consumedCalories = consumedCalories
        self.foodDatas = foodDatas
        self.showNutritionInfo = showNutritionInfo
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        iconImageView.image = icon
        titleLabel.text = title
        ateTimeLabel.text = ateTime
        consumedCaloriesLabel.text = "\(consumedCalories) kcal"
        
        self.addSubview(containerView)
        self.backgroundColor = .clear
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let titleStackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = 8
        titleStackView.layer.cornerRadius = 16
        titleStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        titleStackView.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        
        let foodStackView = UIStackView()
        foodStackView.axis = .vertical
        
        for (index, food) in foodDatas.enumerated() {
            let mealLogFoodView = MealLogFoodView(dietFoodData: food, showNutrientInfo: showNutritionInfo)

            mealLogFoodView.snp.makeConstraints { make in
                make.height.equalTo(72)
            }
            foodStackView.addArrangedSubview(mealLogFoodView)

            if index < foodDatas.count - 1 {
                let separatorContainer = UIView()
                let separator = UIView()
                separator.backgroundColor = .lightGray.withAlphaComponent(0.2)
                
                separatorContainer.addSubview(separator)
                separator.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.height.equalTo(1)
                    make.centerY.equalToSuperview()
                }
                
                separatorContainer.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
                
                foodStackView.addArrangedSubview(separatorContainer)
            }
        }

        
        [titleStackView, consumedCaloriesLabel, foodStackView].forEach { containerView.addSubview($0) }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        consumedCaloriesLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleStackView)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }

        foodStackView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func makeCalorie(carbon: Double, protein: Double, fat: Double) -> Double {
        return carbon * 4 + protein * 4 + fat * 9
    }
}

final class MealLogFoodView: UIView {
    private let dietFoodData: DietFoodData
    private let showNutrientInfo: Bool
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        return label
    }()
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    private let calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemRed
        return label
    }()
    private let carbonLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .carbonText
        return label
    }()
    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .proteinText
        return label
    }()
    private let fatLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .fatText
        return label
    }()
    
    init(dietFoodData: DietFoodData, showNutrientInfo: Bool = false) {
        self.dietFoodData = dietFoodData
        self.showNutrientInfo = showNutrientInfo
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        titleLabel.text = dietFoodData.name
        amountLabel.text = "\(dietFoodData.intake) \(dietFoodData.unit)"
        calorieLabel.text = String(format: "%.1f kcal", makeCalorie(carbon: dietFoodData.carbohydrates, protein: dietFoodData.protein, fat: dietFoodData.fat))
        
        let rightStackSubviews: [UIView] = {
            if showNutrientInfo {
                carbonLabel.text = String(format: "탄: %.1fg", dietFoodData.carbohydrates)
                proteinLabel.text = String(format: "단: %.1fg", dietFoodData.protein)
                fatLabel.text = String(format: "지: %.1fg", dietFoodData.fat)
                let nutritionStack = UIStackView(arrangedSubviews: [carbonLabel, proteinLabel, fatLabel])
                nutritionStack.axis = .horizontal
                nutritionStack.spacing = 8
                return [calorieLabel, nutritionStack]
            } else {
                return [calorieLabel]
            }
        }()
        
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
        leftStackView.axis = .vertical
        leftStackView.spacing = 0
        
        let rightStackView = UIStackView(arrangedSubviews: rightStackSubviews)
        rightStackView.axis = .vertical
        rightStackView.alignment = .trailing
        rightStackView.spacing = 0
        
        addSubview(leftStackView)
        addSubview(rightStackView)
        
        leftStackView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(16)
        }
        rightStackView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(16)
        }
    }


    
    private func makeCalorie(carbon: Double, protein: Double, fat: Double) -> Double {
        return carbon * 4 + protein * 4 + fat * 9
    }
}

enum ConsumedNutrientItemType {
    case sugar
    case carbohydrate
    case protein
    case fat
}

final class ConsumedNutirientItemView: UIView {
    private let consumedNutrientItemType: ConsumedNutrientItemType
    private let consumedStatistics: Int
    
    private var consumedNutrientName: String {
        switch consumedNutrientItemType {
        case .sugar:
            return "당류"
        case .carbohydrate:
            return "탄수화물"
        case .protein:
            return "단백질"
        case .fat:
            return "지방"
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    init(consumedNutrientItemType: ConsumedNutrientItemType, consumedStatistics: Int) {
        self.consumedNutrientItemType = consumedNutrientItemType
        self.consumedStatistics = consumedStatistics
        super.init(frame: .zero)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.addSubview(nameLabel)
        self.addSubview(valueLabel)
        
        nameLabel.text = consumedNutrientName
        valueLabel.text = "\(consumedStatistics)g"
        
        nameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
    }
}
