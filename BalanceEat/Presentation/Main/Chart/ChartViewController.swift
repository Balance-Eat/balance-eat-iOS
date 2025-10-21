//
//  ChartViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ChartViewController: BaseViewController<ChartViewModel> {
    private let headerView = ChartHeaderView()
    private let statStackView = ChartStatStackView()
    
    init() {
        let vm = ChartViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
        setUpView()
        setBinding()
    }
    
    private func setupHeaderView() {
        topContentView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpView() {
        
        [statStackView].forEach(mainStackView.addArrangedSubview(_:))
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        Observable.combineLatest(headerView.periodRelay, headerView.nutritionStatRelay)
            .subscribe(onNext: { [weak self] period, nutritionStat in
                guard let self else { return }
                
                statStackView.statRelay.accept(nutritionStat)
            })
            .disposed(by: disposeBag)
    }
}

final class ChartHeaderView: UIView {
    private let chartPeriodSelectView = ChartPeriodSelectView()
    private let chartNutritionStatsSelectView = ChartNutritionStatsSelectView()
    
    let periodRelay: BehaviorRelay<Period> = .init(value: .daily)
    let nutritionStatRelay: BehaviorRelay<NutritionStat> = .init(value: .calorie)
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setUpView()
        setBinding()
    }
    
    private func setUpView() {
        backgroundColor = .white
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        
        [chartPeriodSelectView, chartNutritionStatsSelectView].forEach {
            stackView.addArrangedSubview($0)
            
            let seperatorView = UIView()
            seperatorView.backgroundColor = .lightGray.withAlphaComponent(0.2)
            seperatorView.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
            stackView.addArrangedSubview(seperatorView)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setBinding() {
        chartPeriodSelectView.periodRelay
            .bind(to: periodRelay)
            .disposed(by: disposeBag)
        
        chartNutritionStatsSelectView.nutritionRelay
            .bind(to: nutritionStatRelay)
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ChartPeriodSelectView: UIView {
    private let dailyButton = SelectableTitledButton(
        title: "일별",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.3),
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let weeklyButton = SelectableTitledButton(
        title: "주별", style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.3),
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let monthlyButton = SelectableTitledButton(
        title: "월별", style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .blue.withAlphaComponent(0.3),
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    
    private lazy var periodButtons = [dailyButton, weeklyButton, monthlyButton]
    
    let periodRelay: BehaviorRelay<Period> = .init(value: .daily)
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
        let stackView = UIStackView(arrangedSubviews: periodButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setBinding() {
        for button in periodButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self, weak button] isSelected in
                    guard let self = self, let button = button else { return }
                    
                    if isSelected {
                        periodButtons.forEach {
                            if $0 !== button {
                                $0.isSelectedRelay.accept(false)
                            }
                        }
                        switch button {
                            case dailyButton:
                            periodRelay.accept(.daily)
                        case weeklyButton:
                            periodRelay.accept(.weekly)
                        case monthlyButton:
                            periodRelay.accept(.monthly)
                        default:
                            break
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}

final class ChartNutritionStatsSelectView: UIView {
    private let calorieButton = SelectableTitledButton(
        title: "칼로리",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .calorieText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let carbohydrateButton = SelectableTitledButton(
        title: "탄수화물",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .carbonText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let proteinButton = SelectableTitledButton(
        title: "단백질",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .proteinText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let fatButton = SelectableTitledButton(
        title: "지방",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .fatText,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private let weightButton = SelectableTitledButton(
        title: "체중",
        style: .init(
            backgroundColor: .lightGray.withAlphaComponent(0.2),
            titleColor: .gray,
            borderColor: nil,
            gradientColors: nil,
            selectedBackgroundColor: .orange,
            selectedTitleColor: .white,
            selectedBorderColor: nil,
            selectedGradientColors: nil
        )
    )
    private lazy var nutritionButtons = [calorieButton, carbohydrateButton, proteinButton, fatButton, weightButton]
    
    let nutritionRelay: BehaviorRelay<NutritionStat> = .init(value: .calorie)
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
        let stackView = UIStackView(arrangedSubviews: nutritionButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setBinding() {
        for button in nutritionButtons {
            button.isSelectedRelay
                .subscribe(onNext: { [weak self, weak button] isSelected in
                    guard let self = self, let button = button else { return }
                    
                    if isSelected {
                        nutritionButtons.forEach {
                            if $0 !== button {
                                $0.isSelectedRelay.accept(false)
                            }
                        }
                        
                        switch button {
                            case calorieButton:
                            nutritionRelay.accept(.calorie)
                        case carbohydrateButton:
                            nutritionRelay.accept(.carbohydrate)
                        case proteinButton:
                            nutritionRelay.accept(.protein)
                        case fatButton:
                            nutritionRelay.accept(.fat)
                        case weightButton:
                            nutritionRelay.accept(.weight)
                        default:
                            break
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}

final class ChartStatStackView: UIView {
    private let averageStatAmountView = ChartStatAmountView(title: "평균")
    private let maxStatAmountView = ChartStatAmountView(title: "최고", isMax: true)
    private let minStatAmountView = ChartStatAmountView(title: "최저", isMin: true)
    
    let averageAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    let maxAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    let minAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    let statRelay: BehaviorRelay<NutritionStat> = .init(value: .calorie)
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
        let stackView = UIStackView(arrangedSubviews: [averageStatAmountView, maxStatAmountView, minStatAmountView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setBinding() {
        averageAmountRelay
            .bind(to: averageStatAmountView.amountRelay)
            .disposed(by: disposeBag)
        
        maxAmountRelay
            .bind(to: maxStatAmountView.amountRelay)
            .disposed(by: disposeBag)
        
        minAmountRelay
            .bind(to: minStatAmountView.amountRelay)
            .disposed(by: disposeBag)
        
        statRelay
            .subscribe(onNext: { [weak self] stat in
                guard let self else { return }
                
                [averageStatAmountView, maxStatAmountView, minStatAmountView].forEach {
                    $0.statRelay.accept(stat)
                }
            })
            .disposed(by: disposeBag)
    }
}

final class ChartStatAmountView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    let amountRelay: BehaviorRelay<Double> = .init(value: 0)
    let statRelay: BehaviorRelay<NutritionStat> = .init(value: .calorie)
    private let disposeBag = DisposeBag()
    
    init(title: String, isMax: Bool = false, isMin: Bool = false) {
        super.init()
        titleLabel.text = title
        amountLabel.textColor = isMax ? .blue : isMin ? .red : .black
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel, unitLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        amountRelay
            .map { String(format: "%.0f", $0) }
            .bind(to: amountLabel.rx.text)
            .disposed(by: disposeBag)
        
        statRelay
            .subscribe(onNext: { [weak self] stat in
                guard let self else { return }
                
                switch stat {
                case .calorie:
                    unitLabel.text = "kcal"
                case .carbohydrate, .protein, .fat:
                    unitLabel.text = "g"
                case .weight:
                    unitLabel.text = "kg"
                }
            })
            .disposed(by: disposeBag)
    }
}
