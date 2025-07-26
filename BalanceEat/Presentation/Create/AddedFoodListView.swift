//
//  AddedFoodListView.swift
//  BalanceEat
//
//  Created by 김견 on 7/21/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum NutritionType {
    case calorie
    case carbon
    case protein
    case fat
}

struct AddedFoodItem {
    let foodName: String
    let amount: String
    let calorie: Double
    let carbon: Double
    let protein: Double
    let fat: Double
}

final class AddedFoodListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let foodItems: [AddedFoodItem] = [
        AddedFoodItem(foodName: "닭가슴살", amount: "1인분 (100g)", calorie: 165, carbon: 0, protein: 31, fat: 3.6),
        AddedFoodItem(foodName: "샐러드", amount: "1인분 (150g)", calorie: 35, carbon: 3, protein: 40, fat: 5.6),
        AddedFoodItem(foodName: "피자", amount: "1인분 (200g)", calorie: 400, carbon: 50, protein: 31, fat: 18.6)
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "추가된 음식"
        return label
    }()
    private let tableView = UITableView()
    private var tableViewHeightConstraint: Constraint?
    
    private lazy var totalNutritionInfo = TotalNutritionalInfoView(foodItems: foodItems)
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddedFoodCell.self, forCellReuseIdentifier: "AddedFoodCell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        self.addSubview(titleLabel)
        self.addSubview(tableView)
        self.addSubview(totalNutritionInfo)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            self.tableViewHeightConstraint = make.height.equalTo(0).constraint
        }
        
        totalNutritionInfo.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        updateTableViewHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddedFoodCell", for: indexPath) as? AddedFoodCell else {
            return UITableViewCell()
        }
        
        let foodItem = foodItems[indexPath.row]
        cell.configure(foodName: foodItem.foodName, amount: foodItem.amount, nutrition: "\(foodItem.calorie)kcal 탄 (\(foodItem.carbon)g 단 \(foodItem.protein)g 지 \(foodItem.fat)g 지방)")
        
        return cell
    }
    
    private func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height
        tableViewHeightConstraint?.update(offset: height)
    }
}

final class AddedFoodCell: UITableViewCell {
    
    private let containerView = HomeMenuContentView()
    
    private let foodNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    
    private let foodAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let foodNutritionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .right
        return label
    }()
    
    private lazy var bottomInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [foodAmountLabel, foodNutritionLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.setBackgroundColor(.favoriteFoodBackground)
        
        containerView.addSubview(foodNameLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(bottomInfoStackView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        }
        
        foodNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(12)
            make.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-8)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(24)
        }
        
        bottomInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(foodNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(foodName: String, amount: String, nutrition: String) {
        foodNameLabel.text = foodName
        foodAmountLabel.text = amount
        foodNutritionLabel.text = nutrition
    }
}


final class TotalNutritionalInfoView: UIView {
    private let foodItems: [AddedFoodItem]
    
    private let contentView = HomeMenuContentView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 영양정보"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .totalNutiritionInfoTitle
        return label
    }()
    
    private lazy var calorieInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .calorie, value: foodItems.map { $0.calorie }.reduce(0, +))
    private lazy var carbonInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .carbon, value: foodItems.map { $0.carbon }.reduce(0, +))
    private lazy var proteinInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .protein, value: foodItems.map { $0.protein }.reduce(0, +))
    private lazy var fatInfoView: NutritionInfoView = NutritionInfoView(nutritionType: .fat, value: foodItems.map { $0.fat }.reduce(0, +))
    
    init(foodItems: [AddedFoodItem]) {
        self.foodItems = foodItems
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
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

final class NutritionInfoView: UIView {
    private let nutritionType: NutritionType
    private let value: Double
    
    private lazy var textColor: UIColor = {
        switch nutritionType {
        case .calorie:
                .calorieText
        case .carbon:
                .carbonText
        case .protein:
                .proteinText
        case .fat:
                .fatText
        }
    }()
    private lazy var titleString: String = {
        switch nutritionType {
        case .calorie:
            "칼로리"
        case .carbon:
            "탄수화물"
        case .protein:
            "단백질"
        case .fat:
            "지방"
        }
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            label.text = String(format: "%.0f", value) + (nutritionType == .calorie ? "" : "g")
        } else {
            label.text = String(format: "%.1f", value) + (nutritionType == .calorie ? "" : "g")
        }
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }()

    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleString
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }()
    
    init(nutritionType: NutritionType, value: Double) {
        self.nutritionType = nutritionType
        self.value = value
        super.init(frame: .zero)
        
        setUpView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
