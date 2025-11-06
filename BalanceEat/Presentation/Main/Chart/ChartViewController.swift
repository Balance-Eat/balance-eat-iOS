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
import DGCharts

class ChartViewController: BaseViewController<ChartViewModel> {
    private let refreshControl = UIRefreshControl()
    private let headerView = ChartHeaderView()
    private let statStackView = ChartStatStackView()
    private let periodChangeView = PeriodChangeView()
    private let statsGraphView = StatsGraphView()
    private let achievementRateListView = AchievementRateListView()
    private let analysisInsightView = AnalysisInsightView()
    
    init() {
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        let statsRepository = StatsRepository()
        let statsUseCase = StatsUseCase(repository: statsRepository)
        let vm = ChartViewModel(userUseCase: userUseCase, statsUseCase: statsUseCase)
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
        getUser()
    }
    
    private func setupHeaderView() {
        topContentView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setUpView() {
        scrollView.refreshControl = refreshControl
        
        [statStackView, periodChangeView, statsGraphView, achievementRateListView, analysisInsightView].forEach(mainStackView.addArrangedSubview(_:))
        
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        statsGraphView.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
    }
    
    private func setBinding() {
        headerView.periodRelay
            .subscribe(onNext: { [weak self] period in
                guard let self else { return }
                
                if let stats = viewModel.cachedStats[period.rawValue] {
                    viewModel.currentStatsRelay.accept(stats)
                } else {
                    Task {
                        await self.viewModel.getStats(period: period)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                
                let period = headerView.periodRelay.value
                Task {
                    await self.viewModel.getStats(period: period)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.refreshControl.endRefreshing()
                    }
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.currentStatsRelay, headerView.nutritionStatTypeRelay)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stats, nutritionStatType in
                guard let self else { return }
                
                statStackView.statsRelay.accept(stats)
                statStackView.nutritionStatTypeRelay.accept(nutritionStatType)
                
                periodChangeView.statsRelay.accept(stats)
                periodChangeView.nutritionStatRelay.accept(nutritionStatType)
                
                statsGraphView.statsRelay.accept(stats)
                statsGraphView.nutritionStatTypeRelay.accept(nutritionStatType)
                
                achievementRateListView.statsRelay.accept(stats)
                achievementRateListView.nutritionStatTypeRelay.accept(nutritionStatType)
                
                analysisInsightView.statsRelay.accept(stats)
                analysisInsightView.nutritionStatTypeRelay.accept(nutritionStatType)
            })
            .disposed(by: disposeBag)
        
        viewModel.userDataRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] userData in
                guard let self else { return }
                achievementRateListView.userDataRelay.accept(userData)
                analysisInsightView.userDataRelay.accept(userData)
            })
            .disposed(by: disposeBag)
    }
    
    private func getUser() {
        Task {
            await viewModel.getUser()
        }
    }
}

final class ChartHeaderView: UIView {
    private let chartPeriodSelectView = ChartPeriodSelectView()
    private let chartNutritionStatsSelectView = ChartNutritionStatsSelectView()
    
    let periodRelay: BehaviorRelay<Period> = .init(value: .daily)
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
            .bind(to: nutritionStatTypeRelay)
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
        dailyButton.isSelectedRelay.accept(true)
        
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
    private lazy var nutritionButtons = [calorieButton, carbohydrateButton, proteinButton, fatButton]
    
    let nutritionRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
        calorieButton.isSelectedRelay.accept(true)
        
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
//                        case weightButton:
//                            nutritionRelay.accept(.weight)
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
    
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    private let averageAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    private let maxAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    private let minAmountRelay: BehaviorRelay<Double> = .init(value: 0)
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
        
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType in
                guard let self else { return }
                var sum: Double = 0
                var max: Double = 0
                var min: Double = 0
                
                switch nutritionStatType {
                case .calorie:
                    sum = stats.reduce(0) { $0 + $1.totalCalories }
                    max = stats.map(\.totalCalories).max() ?? 0
                    min = stats.map(\.totalCalories).min() ?? 0
                    
                    averageAmountRelay.accept(sum / Double(stats.count))
                    maxAmountRelay.accept(max)
                    minAmountRelay.accept(min)
                case .carbohydrate:
                    sum = stats.reduce(0) { $0 + $1.totalCarbohydrates }
                    max = stats.map(\.totalCarbohydrates).max() ?? 0
                    min = stats.map(\.totalCarbohydrates).min() ?? 0
                    
                    averageAmountRelay.accept(sum / Double(stats.count))
                    maxAmountRelay.accept(max)
                    minAmountRelay.accept(min)
                case .protein:
                    sum = stats.reduce(0) { $0 + $1.totalProtein }
                    max = stats.map(\.totalProtein).max() ?? 0
                    min = stats.map(\.totalProtein).min() ?? 0
                    
                    averageAmountRelay.accept(sum / Double(stats.count))
                    maxAmountRelay.accept(max)
                    minAmountRelay.accept(min)
                case .fat:
                    sum = stats.reduce(0) { $0 + $1.totalFat }
                    max = stats.map(\.totalFat).max() ?? 0
                    min = stats.map(\.totalFat).min() ?? 0
                    
                    averageAmountRelay.accept(sum / Double(stats.count))
                    maxAmountRelay.accept(max)
                    minAmountRelay.accept(min)
//                case .weight:
//                    sum = stats.reduce(0) { $0 + $1.weight }
//                    max = stats.map(\.weight).max() ?? 0
//                    min = stats.map(\.weight).min() ?? 0
//                    
//                    averageAmountRelay.accept(sum / Double(stats.count))
//                    maxAmountRelay.accept(max)
//                    minAmountRelay.accept(min)
                }
                
                [averageStatAmountView, maxStatAmountView, minStatAmountView].forEach {
                    $0.statRelay.accept(nutritionStatType)
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
    let statRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
//                case .weight:
//                    unitLabel.text = "kg"
                }
            })
            .disposed(by: disposeBag)
    }
}

final class PeriodChangeView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.text = "기간 대비 변화"
        return label
    }()
    private let periodChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let differenceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        return label
    }()
    private let differenceContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        differenceContainerView.addSubview(differenceLabel)
        
        differenceLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        [titleLabel, periodChangeLabel, differenceContainerView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        differenceContainerView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        periodChangeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatRelay)
            .subscribe(onNext: { [weak self] statsDatas, nutritionStat in
                guard let self else { return }
                let firstDate = extractMonthAndDay(from: statsDatas.first?.date ?? "")
                var firstNutritionAmount: Double = 0
                let lastDate = extractMonthAndDay(from: statsDatas.last?.date ?? "")
                var lastNutritionAmount: Double = 0
                
                switch nutritionStat {
                case .calorie:
                    firstNutritionAmount = statsDatas.first?.totalCalories ?? 0
                    lastNutritionAmount = statsDatas.last?.totalCalories ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)kcal → \(lastDate): \(lastNutritionAmount)kcal"
                case .carbohydrate:
                    firstNutritionAmount = statsDatas.first?.totalCarbohydrates ?? 0
                    lastNutritionAmount = statsDatas.last?.totalCarbohydrates ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)g → \(lastDate): \(lastNutritionAmount)g"
                case .protein:
                    firstNutritionAmount = statsDatas.first?.totalProtein ?? 0
                    lastNutritionAmount = statsDatas.last?.totalProtein ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)g → \(lastDate): \(lastNutritionAmount)g"
                case .fat:
                    firstNutritionAmount = statsDatas.first?.totalFat ?? 0
                    lastNutritionAmount = statsDatas.last?.totalFat ?? 0
                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)g → \(lastDate): \(lastNutritionAmount)g"
//                case .weight:
//                    firstNutritionAmount = statsDatas.first?.weight ?? 0
//                    lastNutritionAmount = statsDatas.last?.weight ?? 0
//                    periodChangeLabel.text = "\(firstDate): \(firstNutritionAmount)kg → \(lastDate): \(lastNutritionAmount)kg"
                }
                
                let diff = lastNutritionAmount - firstNutritionAmount
                
                if diff > 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 증가", diff, nutritionStat.unit)
                    self.differenceLabel.textColor = .systemBlue
                    self.differenceContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
                } else if diff < 0 {
                    self.differenceLabel.text = String(format: "%.1f%@ 감소", abs(diff), nutritionStat.unit)
                    self.differenceLabel.textColor = .systemRed
                    self.differenceContainerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                } else {
                    self.differenceLabel.text = "변화 없음"
                    self.differenceLabel.textColor = .systemGray
                    self.differenceContainerView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func extractMonthAndDay(from dateString: String) -> String {
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return "" }
        return "\(components[1])-\(components[2])"
    }

}

final class StatsGraphView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let lineChartView: LineChartView = {
        let chart = LineChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        addSubview(titleLabel)
        addSubview(lineChartView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(16)
        }
        
        lineChartView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType in
                guard let self else { return }
                
                var entries: [ChartDataEntry] = []
                let labels = stats.map { [weak self] stat in
                    guard let self else { return "" }
                    return extractMonthAndDay(from: stat.date)
                }
                
                for i in 0..<stats.count {
                    switch nutritionStatType {
                    case .calorie:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalCalories))
                    case .carbohydrate:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalCarbohydrates))
                    case .protein:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalProtein))
                    case .fat:
                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].totalFat))
//                    case .weight:
//                        entries.append(ChartDataEntry(x: Double(i), y: stats[i].weight))
                    }
                }
                
                var label: String
                var color: UIColor
                
                switch nutritionStatType {
                    case .calorie:
                    label = "칼로리"
                    color = .calorieText
                    titleLabel.text = "칼로리 추이"
                case .carbohydrate:
                    label = "탄수화물"
                    color = .carbonText
                    titleLabel.text = "탄수화물 추이"
                case .protein:
                    label = "단백질"
                    color = .proteinText
                    titleLabel.text = "단백질 추이"
                case .fat:
                    label = "지방"
                    color = .fatText
                    titleLabel.text = "지방 추이"
//                case .weight:
//                    label = "체중"
//                    color = .yellow
//                    titleLabel.text = "체중 추이"
                }
                
                let dataSet = LineChartDataSet(entries: entries, label: label)
                dataSet.colors = [color]
                dataSet.circleColors = [.systemBlue]
                dataSet.lineWidth = 2
                dataSet.circleRadius = 5
                dataSet.mode = .horizontalBezier
                
                let data = LineChartData(dataSet: dataSet)
                lineChartView.data = data
                
                lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
                lineChartView.xAxis.granularity = 1
                lineChartView.xAxis.labelPosition = .bottom
                
                lineChartView.rightAxis.enabled = false
                lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                
                let count = Double(labels.count)
                lineChartView.xAxis.axisMinimum = -0.5
                lineChartView.xAxis.axisMaximum = count - 0.5
            })
            .disposed(by: disposeBag)
    }

    private func extractMonthAndDay(from dateString: String) -> String {
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return "" }
        return "\(components[1])-\(components[2])"
    }
}

final class AchievementRateListView: BalanceEatContentView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.text = "목표 달성률"
        return label
    }()
    private let tableView = UITableView()
    private var tableHeightConstraint: Constraint?
    
    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
    
    let achievementRateStatsRelay: BehaviorRelay<[AchievementRateStat]> = .init(value: [])
    private let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        setUpView()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        [titleLabel, tableView].forEach(addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(4)
            self.tableHeightConstraint = make.height.equalTo(0).constraint
        }
        
        tableView.backgroundColor = .clear
        tableView.register(AchievementRateCell.self, forCellReuseIdentifier: "AchievementRateCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay, userDataRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType, userData in
                guard let self else { return }
                
                var achievementRateStats: [AchievementRateStat] = []
                
                for stat in stats {
                    var percent: Double = 0.0
                                        
                    switch nutritionStatType {
                    case .calorie:
                        percent = (stat.totalCalories / Double((userData?.targetCalorie ?? 1))) * 100
                    case .carbohydrate:
                        percent = (stat.totalCarbohydrates / (userData?.targetCarbohydrates ?? 1)) * 100
                    case .protein:
                        percent = (stat.totalProtein / (userData?.targetProtein ?? 1)) * 100
                    case .fat:
                        percent = (stat.totalFat / (userData?.targetFat ?? 1)) * 100
//                    case .weight:
//                        percent = (stat.weight / (userData?.targetWeight ?? 1)) * 100
                    }
                    
                    let achievementRateStat = AchievementRateStat(date: extractMonthAndDay(from: stat.date), percent: percent)
                    achievementRateStats.append(achievementRateStat)
                }
                
                achievementRateStatsRelay.accept(achievementRateStats)
            })
            .disposed(by: disposeBag)
        
        achievementRateStatsRelay
            .bind(to: tableView.rx.items(
                cellIdentifier: "AchievementRateCell",
                cellType: AchievementRateCell.self)
            ) { _, stat, cell in
                cell.configure(stat: stat)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0?.height }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] height in
                self?.tableHeightConstraint?.update(offset: height)
                self?.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
    
    private func extractMonthAndDay(from dateString: String) -> String {
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return "" }
        return "\(components[1])-\(components[2])"
    }
}

final class AchievementRateCell: UITableViewCell {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        return label
    }()
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.trackTintColor = .systemGray5
        return progressView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        self.backgroundColor = .clear
        
        let labelStack = UIStackView(arrangedSubviews: [dateLabel, percentLabel])
        labelStack.axis = .horizontal
        labelStack.distribution = .fillEqually
        
        let contentStack = UIStackView(arrangedSubviews: [labelStack, progressView])
        contentStack.axis = .vertical
        contentStack.spacing = 6
        
        contentView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        progressView.snp.makeConstraints { make in
            make.height.equalTo(8)
        }
    }
    
    func configure(stat: AchievementRateStat) {
        dateLabel.text = stat.date
        percentLabel.text = "\(Int(stat.percent))%"
        
        let progress = Float(stat.percent / 100)
        progressView.setProgress(progress, animated: false)
        
        if stat.percent > 100 {
            progressView.progressTintColor = .systemRed
        } else {
            progressView.progressTintColor = .systemGreen
        }
    }
}

final class AnalysisInsightView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .blue.withAlphaComponent(0.8)
        label.text = "💡 분석 인사이트"
        return label
    }()
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .blue
        label.numberOfLines = 0
        return label
    }()
    
    let userDataRelay: BehaviorRelay<UserData?> = .init(value: nil)
    let statsRelay: BehaviorRelay<[StatsData]> = .init(value: [])
    let nutritionStatTypeRelay: BehaviorRelay<NutritionStatType> = .init(value: .calorie)
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
        self.backgroundColor = .blue.withAlphaComponent(0.03)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blue.withAlphaComponent(0.1).cgColor
        
        [titleLabel, contentLabel].forEach(addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setBinding() {
        Observable.combineLatest(statsRelay, nutritionStatTypeRelay, userDataRelay)
            .subscribe(onNext: { [weak self] stats, nutritionStatType, userData in
                guard let self else { return }
                
                var average: Double = 0
                var target: Double = 0
                var isInTargetCount: Int = 0
                
                switch nutritionStatType {
                case .calorie:
                    average = stats.map(\.totalCalories).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetCalorie ?? 1)
                    
                    stats.forEach { stat in
                        if stat.totalCalories <= target {
                            isInTargetCount += 1
                        }
                    }
                case .carbohydrate:
                    average = stats.map(\.totalCarbohydrates).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetCarbohydrates ?? 1)
                    
                    stats.forEach { stat in
                        if stat.totalCarbohydrates <= target {
                            isInTargetCount += 1
                        }
                    }
                case .protein:
                    average = stats.map(\.totalProtein).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetProtein ?? 1)
                    
                    stats.forEach { stat in
                        if stat.totalProtein <= target {
                            isInTargetCount += 1
                        }
                    }
                case .fat:
                    average = stats.map(\.totalFat).reduce(0, +) / Double(stats.count)
                    target = Double(userData?.targetFat ?? 1)
                    
                    stats.forEach { stat in
                        if stat.totalFat <= target {
                            isInTargetCount += 1
                        }
                    }
//                case .weight:
//                    average = stats.map(\.weight).reduce(0, +) / Double(stats.count)
//                    target = Double(userData?.targetWeight ?? 1)
//                    
//                    stats.forEach { stat in
//                        if stat.weight <= target {
//                            isInTargetCount += 1
//                        }
//                    }
                }
                let contentString = """
                                • 평균 \(String(format: "%.0f", average))\(nutritionStatType.unit)로 목표 대비 \(String(format: "%.1f", abs((average - target) / target) * 100))% 초과입니다.
                                • \(isInTargetCount)일이 목표 범위 내에 있습니다.
                                """
                contentLabel.setTextWithLineSpacing(contentString, lineSpacing: 6)
            })
            .disposed(by: disposeBag)
    }
}
