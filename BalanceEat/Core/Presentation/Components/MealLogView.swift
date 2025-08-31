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
    private let ateTime: Date
    private let consumedFoodAmount: Int
    private let consumedCalories: Int
    private let consumedSugars: Int
    private let consumedCarbohydrates: Int
    private let consumedProteins: Int
    private let consumedFats: Int
    
    private let containerView: UIView = UIView()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
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
    private let consumedFoodAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    private let nutrientStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
//    private lazy var consumedSugarView = ConsumedNutirientItemView(consumedNutrientItemType: .sugar, consumedStatistics: consumedSugars)
    private lazy var consumedCarbohydratesView = ConsumedNutirientItemView(consumedNutrientItemType: .carbohydrate, consumedStatistics: consumedCarbohydrates)
    private lazy var consumedProteinsView = ConsumedNutirientItemView(consumedNutrientItemType: .protein, consumedStatistics: consumedProteins)
    private lazy var consumedFatsView = ConsumedNutirientItemView(consumedNutrientItemType: .fat, consumedStatistics: consumedFats)
    
    init(icon: UIImage? = nil, title: String, ateTime: Date, consumedFoodAmount: Int, consumedCalories: Int, consumedSugars: Int, consumedCarbohydrates: Int, consumedProteins: Int, consumedFats: Int) {
        self.icon = icon
        self.title = title
        self.ateTime = ateTime
        self.consumedFoodAmount = consumedFoodAmount
        self.consumedCalories = consumedCalories
        self.consumedSugars = consumedSugars
        self.consumedCarbohydrates = consumedCarbohydrates
        self.consumedProteins = consumedProteins
        self.consumedFats = consumedFats
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        iconImageView.image = icon
        titleLabel.text = title
        ateTimeLabel.text = formattedTime(from: ateTime)
        consumedFoodAmountLabel.text = "\(consumedFoodAmount)g"
        consumedCaloriesLabel.text = "\(consumedCalories) kcal"
        
        self.addSubview(containerView)
        
        [iconImageView, titleLabel, ateTimeLabel, consumedCaloriesLabel, consumedFoodAmountLabel, nutrientStackView].forEach {
            containerView.addSubview($0)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
//        iconImageView.snp.makeConstraints { make in
//            make.top.leading.equalToSuperview()
//            make.width.height.equalTo(30)
//        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        ateTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        consumedFoodAmountLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
        }
        
        consumedCaloriesLabel.snp.makeConstraints { make in
            make.top.equalTo(consumedFoodAmountLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }

        nutrientStackView.snp.makeConstraints { make in
            make.top.equalTo(consumedCaloriesLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
//        nutrientStackView.addArrangedSubview(consumedSugarView)
        nutrientStackView.addArrangedSubview(consumedCarbohydratesView)
        nutrientStackView.addArrangedSubview(consumedProteinsView)
        nutrientStackView.addArrangedSubview(consumedFatsView)
    }
    
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        
        return formatter.string(from: date)
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
