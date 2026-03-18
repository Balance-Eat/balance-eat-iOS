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
        tableView.rowHeight = 220
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
            make.top.equalTo(titleLabel.snp.bottom).inset(8)
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
        cell.configure(foodData: foodItem)

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
