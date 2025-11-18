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
    private var foodItems: [DietFoodData] = []
    let foodItemsRelay: BehaviorRelay<[DietFoodData]> = BehaviorRelay(value: [])
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "추가된 음식"
        return label
    }()
    private var emptyLabelHeightConstraint: Constraint?
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "추가된 음식이 없습니다"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    private let tableView = UITableView()
    private var tableViewHeightConstraint: Constraint?
    
    private lazy var sumOfNutritionValueView = SumOfNutritionValueView(title: "총 영양소")
    
    /// (Calorie, Carbon, Protein, Fat)
    private let cellNutritionRelay = BehaviorRelay<[String: (Double, Double, Double, Double)]>(value: [:])
    let cellIntakeRelay = BehaviorRelay<[Int: Double]>(value: [:])
    
    let deletedFoodItem = PublishRelay<DietFoodData>()
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddedFoodCell.self, forCellReuseIdentifier: "AddedFoodCell")
        tableView.rowHeight = 210
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        self.addSubview(titleLabel)
        self.addSubview(tableView)
        self.addSubview(emptyLabel)
        self.addSubview(sumOfNutritionValueView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview()
            self.emptyLabelHeightConstraint = make.height.equalTo(0).constraint
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            self.tableViewHeightConstraint = make.height.equalTo(0).constraint
        }
        
        sumOfNutritionValueView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        updateTableViewHeight()
    }
    
    private func setBinding() {
        cellNutritionRelay
            .map { dict -> (Double, Double, Double, Double) in
                let values = dict.values
                let sumCalorie = values.map { $0.0 }.reduce(0, +)
                let sumCarbon  = values.map { $0.1 }.reduce(0, +)
                let sumProtein = values.map { $0.2 }.reduce(0, +)
                let sumFat     = values.map { $0.3 }.reduce(0, +)
                return (sumCalorie, sumCarbon, sumProtein, sumFat)
            }
            .subscribe(onNext: { [weak self] (cal, carbon, protein, fat) in
                guard let self else { return }
                self.sumOfNutritionValueView.calorieRelay.accept(cal)
                self.sumOfNutritionValueView.carbonRelay.accept(carbon)
                self.sumOfNutritionValueView.proteinRelay.accept(protein)
                self.sumOfNutritionValueView.fatRelay.accept(fat)
            })
            .disposed(by: disposeBag)


        foodItemsRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] items in
                guard let self else { return }
                let isEmpty = items.isEmpty
                self.emptyLabel.isHidden = !isEmpty
                
                let emptyLabelHeight: CGFloat = isEmpty ? 40 : 0
                self.emptyLabelHeightConstraint?.update(offset: emptyLabelHeight)
                
                let currentIDs = Set(items.map { String($0.id) })
                var dict = self.cellNutritionRelay.value
                dict.keys.filter { !currentIDs.contains($0) }.forEach { dict.removeValue(forKey: $0) }
                self.cellNutritionRelay.accept(dict)
                
                self.foodItems = items

                    self.tableView.reloadData()
                    self.updateTableViewHeight()
            })
            .disposed(by: disposeBag)
        
        deletedFoodItem
            .withLatestFrom(foodItemsRelay) { deleted, current -> [DietFoodData] in
                current.filter { $0.id != deleted.id }
            }
            .bind(to: foodItemsRelay)
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddedFoodCell", for: indexPath) as? AddedFoodCell else {
            return UITableViewCell()
        }
        
        let foodItem = foodItems[indexPath.row]
        cell.configure(
            foodData: foodItem
        )
        
        cell.closeButtonTapped
            .map { foodItem }
            .bind(to: deletedFoodItem)
            .disposed(by: cell.disposeBag)
        
        cell.nutritionRelay
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                var dict = self.cellNutritionRelay.value
                dict[String(foodItem.id)] = value
                self.cellNutritionRelay.accept(dict)
            })
            .disposed(by: cell.disposeBag)
        
        cell.intakeRelay
            .subscribe(onNext: { [weak self] intake in
                guard let self else { return }
                var dict = self.cellIntakeRelay.value
                dict[foodItem.id] = intake
                self.cellIntakeRelay.accept(dict)
                
                
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    private func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        let height = tableView.contentSize.height
        tableViewHeightConstraint?.update(offset: height)
    }
    
    func deleteItem(at indexPath: IndexPath) {
        guard indexPath.row < foodItems.count else { return }

        let food = foodItems[indexPath.row]
        
        tableView.beginUpdates()
        foodItems.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        
        var dict = cellNutritionRelay.value
        dict.removeValue(forKey: String(food.id))
        cellNutritionRelay.accept(dict)
        
        self.updateTableViewHeight()
        self.layoutIfNeeded()
    }
}

final class AddedFoodCell: UITableViewCell {
    private var foodData: DietFoodData?
    private var intake: Double = 0
    
    private let containerView = UIView()
    
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
    
    private let twoOptionPickerView = TwoOptionPickerView(firstText: "1인분", secondText: "단위")
    
    private let stepperView = StepperView()
    
    private let nutritionalInfoView: TotalNutritionalInfoView
    
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
    
    let nutritionRelay = BehaviorRelay<(Double, Double, Double, Double)>(value: (0,0,0,0))
    let intakeRelay = BehaviorRelay<Double>(value: 0)
    let closeButtonTapped = PublishRelay<Void>()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.nutritionalInfoView = TotalNutritionalInfoView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        setupView()
        setupConstraints()
//        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func setupView() {
        self.backgroundColor = .clear
        contentView.addSubview(containerView)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        
        containerView.addSubview(foodNameLabel)
        containerView.addSubview(twoOptionPickerView)
        containerView.addSubview(stepperView)
        containerView.addSubview(closeButton)
        containerView.addSubview(bottomInfoStackView)
        containerView.addSubview(nutritionalInfoView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        foodNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        let inputStackView = UIStackView(arrangedSubviews: [twoOptionPickerView, stepperView])
        inputStackView.axis = .horizontal
        inputStackView.distribution = .equalSpacing
        inputStackView.spacing = 8
        
        addSubview(inputStackView)
        
        inputStackView.snp.makeConstraints { make in
            make.top.equalTo(foodNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        nutritionalInfoView.snp.makeConstraints { make in
            make.top.equalTo(twoOptionPickerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(foodData: DietFoodData) {
        prepareForReuse()
        
        foodNameLabel.text = foodData.name
        self.intake = foodData.intake
        self.foodData = foodData
        
        stepperView.unit = foodData.unit
        stepperView.intake = intake
        stepperView.servingSize = foodData.servingSize
        
        nutritionalInfoView.carbonRelay.accept(foodData.carbohydrates)
        nutritionalInfoView.proteinRelay.accept(foodData.protein)
        nutritionalInfoView.fatRelay.accept(foodData.fat)
        
        closeButton.rx.tap
                .bind(to: closeButtonTapped)
                .disposed(by: disposeBag)
            
        twoOptionPickerView.selectedOption
            .subscribe(onNext: { [weak self] selectedOption in
                guard let self else { return }
                
                switch selectedOption {
                case .first:
                    stepperView.stepValue = intake / foodData.intake
                    stepperView.stepperModeRelay.accept(.servingSize)
                case .second:
                    stepperView.stepValue = intake / foodData.intake
                    stepperView.stepperModeRelay.accept(.amountSize)
                }
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(to: closeButtonTapped)
            .disposed(by: disposeBag)
        
        stepperView.intakeRelay
            .subscribe(onNext: { [weak self] amount in
                guard let self else { return }
                guard let foodData = self.foodData else { return }
                
                let ratio = amount / intake
                                
                nutritionalInfoView.carbonRelay.accept(foodData.carbohydrates * ratio)
                nutritionalInfoView.proteinRelay.accept(foodData.protein * ratio)
                nutritionalInfoView.fatRelay.accept(foodData.fat * ratio)
                
                intakeRelay.accept(amount)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            nutritionalInfoView.carbonRelay,
            nutritionalInfoView.proteinRelay,
            nutritionalInfoView.fatRelay
        ).subscribe(onNext: { [weak self] (carbon, protein, fat) in
            guard let self else { return }
            let calorieRelayValue = 4 * carbon + 4 * protein + 9 * fat
            nutritionalInfoView.calorieRelay.accept(calorieRelayValue)
        })
        .disposed(by: disposeBag)
        
        Observable.combineLatest(
            nutritionalInfoView.calorieRelay,
            nutritionalInfoView.carbonRelay,
            nutritionalInfoView.proteinRelay,
            nutritionalInfoView.fatRelay
        )
        .subscribe(onNext: { [weak self] (cal, carbon, protein, fat) in
            guard let self else { return }

            self.nutritionRelay.accept((cal, carbon, protein, fat))
        })
        .disposed(by: disposeBag)


    }
}


final class NutritionInfoView: UIView {
    private let nutritionType: NutritionType
    
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
    private lazy var viewBackgroundColor: UIColor = {
        switch nutritionType {
        case .calorie:
                .calorieText.withAlphaComponent(0.1)
        case .carbon:
                .carbonText.withAlphaComponent(0.1)
        case .protein:
                .proteinText.withAlphaComponent(0.1)
        case .fat:
                .fatText.withAlphaComponent(0.1)
        }
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }()

    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleString
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let valueRelay = BehaviorRelay<Double>(value: 0)
    
    var valueTextSize: CGFloat = 16 {
        didSet {
            valueLabel.font = .systemFont(ofSize: valueTextSize, weight: .bold)
        }
    }
    var titleTextSize: CGFloat = 12 {
        didSet {
            titleLabel.font = .systemFont(ofSize: titleTextSize, weight: .regular)
        }
    }
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init(nutritionType: NutritionType) {
        self.nutritionType = nutritionType
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = viewBackgroundColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setBinding() {
        valueRelay
            .map { value -> String in
                if value.truncatingRemainder(dividingBy: 1) == 0 {
                    return String(format: "%.0f", value) + (self.nutritionType == .calorie ? "" : "g")
                } else {
                    return String(format: "%.1f", value) + (self.nutritionType == .calorie ? "" : "g")
                }
            }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
