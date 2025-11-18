//
//  ListViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DietListViewController: BaseViewController<DietListViewModel> {
    
    private let headerView = DietListHeaderView()
    private lazy var sumOfNutritionValueView = SumOfNutritionValueView(
        title: "이날의 영양 요약",
        subTitle: "목표 : \(viewModel.userDataRelay.value?.targetCalorie ?? 0)kcal"
    )
    private let todayAteMealLogListView = MealLogListView()
    private let dietEmptyInfoView = DietEmptyInfoView()
    
    init() {
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        let dietRepository = DietRepository()
        let dietUseCase = DietUseCase(repository: dietRepository)
        let vm = DietListViewModel(userUseCase: userUseCase, dietUseCase: dietUseCase)
        super.init(viewModel: vm)
        
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
        setupStackView()
        setBinding()
        getDatas()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            await viewModel.getUser()
            await viewModel.getMonthlyDiets()
        }
    }
    
    private func setupHeaderView() {
        topContentView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupStackView() {
        mainStackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        [sumOfNutritionValueView, todayAteMealLogListView, dietEmptyInfoView].forEach(mainStackView.addArrangedSubview(_:))
    }
    
    private func setBinding() {
        headerView.selectedDate
            .bind(to: viewModel.selectedDate)
            .disposed(by: disposeBag)
        
        headerView.goToTodayButtonTap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                viewModel.selectedDate.accept(Date())
                headerView.selectedDate.accept(Date())
            })
            .disposed(by: disposeBag)
        
        headerView.showNewMonth
            .subscribe(onNext: { [weak self] (year, month) in
                guard let self else { return }
                
                Task {
                    await self.viewModel.getMonthlyDiets(year: year, month: month)
                }
            })
            .disposed(by: disposeBag)
        
        dietEmptyInfoView.buttonTappedRelay
            .subscribe(onNext: { [weak self] in
                self?.goToDiet()
            })
            .disposed(by: disposeBag)
        
        viewModel.userDataRelay
            .subscribe(onNext: { [weak self] userData in
                guard let self, let targetCalorie = userData?.targetCalorie else { return }
                sumOfNutritionValueView.subTitleRelay.accept("목표: \(targetCalorie)kcal")
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedDayDataCache
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] dietDatas in
                guard let self else { return }
                
                let totalCalories = dietDatas.flatMap { $0.items }.map { $0.calories }.reduce(0, +)
                let totalCarbon = dietDatas.flatMap { $0.items }.map { $0.carbohydrates }.reduce(0, +)
                let totalProtein = dietDatas.flatMap { $0.items }.map { $0.protein }.reduce(0, +)
                let totalFat = dietDatas.flatMap { $0.items }.map { $0.fat }.reduce(0, +)
                
                sumOfNutritionValueView.calorieRelay.accept(totalCalories)
                sumOfNutritionValueView.carbonRelay.accept(totalCarbon)
                sumOfNutritionValueView.proteinRelay.accept(totalProtein)
                sumOfNutritionValueView.fatRelay.accept(totalFat)
                
                let mealLogs = dietDatas.map { diet in
                    
                    MealLogView(
                        icon: UIImage(systemName: diet.mealType.icon),
                        title: diet.mealType.title,
                        ateTime: self.extractHourMinute(from: diet.consumedAt) ?? "",
                        consumedCalories: diet.items.reduce(0) { $0 + Int($1.calories) },
                        foodDatas: diet.items,
                        showNutritionInfo: true
                    )
                }
                todayAteMealLogListView.mealLogsRelay.accept(mealLogs)
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedDayDataCache
            .map { $0.isEmpty }
            .bind(to: todayAteMealLogListView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.selectedDayDataCache
            .map { !$0.isEmpty }
            .bind(to: dietEmptyInfoView.rx.isHidden)
            .disposed(by: disposeBag)
        
        todayAteMealLogListView.goToDietButtonTapRelay
            .subscribe(onNext: { [weak self] in
                self?.goToDiet()
            })
            .disposed(by: disposeBag)
        
        viewModel.userDataRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] userData in
                guard let self else { return }
                
                sumOfNutritionValueView.editSubtitleText("목표 : \(String(format: "%.0f", userData?.targetCalorie ?? 0))kcal")
            })
            .disposed(by: disposeBag)
        
        viewModel.ateDateRelay
            .bind(to: headerView.markedDatesRelay)
            .disposed(by: disposeBag)
    }
    
    private func getDatas() {
        Task {
            await viewModel.getUser()
            await viewModel.getMonthlyDiets()
        }
    }
    
    private func extractHourMinute(from dateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        guard let date = formatter.date(from: dateString) else {
            print("dateString parsing failed: \(dateString)")
            return nil
        }
        
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func goToDiet() {
        navigationController?.pushViewController(CreateDietViewController(dietDatas: viewModel.selectedDayDataCache.value, date: viewModel.selectedDate.value), animated: true)
    }
}


final class DietListHeaderView: UIView, UICalendarSelectionSingleDateDelegate, UICalendarViewDelegate {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.text = "식단 내역"
        return label
    }()
    
    private let goToTodayButton: TitledButton = {
        let button = TitledButton(
            title: "오늘",
            style: .init(
                backgroundColor: .lightGray.withAlphaComponent(0.15),
                titleColor: .black,
                borderColor: nil,
                gradientColors: nil
            )
        )
        return button
    }()
    
    private let openCalendarButton = OpenCalendarButton()
    
    private let previousDateButton: CountingButton = {
        let button = CountingButton(image: UIImage(systemName: "chevron.left"))
        return button
    }()
    
    private let nextDateButton: CountingButton = {
        let button = CountingButton(image: UIImage(systemName: "chevron.right"))
        return button
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let calendarView: UICalendarView = {
        let calendar = UICalendarView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }()
    
    
    let markedDatesRelay: BehaviorRelay<Set<Date>> = .init(value: [])
    let showNewMonth: PublishRelay<(Int, Int)> = .init()
    let selectedDate = BehaviorRelay<Date>(value: Date())
    let goToTodayButtonTap = PublishSubject<Void>()
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
        self.backgroundColor = .white
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let formattedDate = formatKoreanDate(formatter.string(from: selectedDate.value)) {
            dateLabel.text = formattedDate
        }
        
        let mainStackview: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 16
            return stackView
        }()
        
        let leftSpacer = UIView()
        let rightSpacer = UIView()

        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, leftSpacer, goToTodayButton, rightSpacer, openCalendarButton])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.spacing = 8

        leftSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        calendarView.delegate = self
        
        let dateStackView = UIStackView(arrangedSubviews: [previousDateButton, dateLabel, nextDateButton])
        dateStackView.axis = .horizontal
        dateStackView.distribution = .equalSpacing
        dateStackView.alignment = .center
        
        [titleStackView, dateStackView, separatorView, calendarView].forEach { mainStackview.addArrangedSubview($0) }
       
        addSubview(mainStackview)
        
        mainStackview.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        previousDateButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        nextDateButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
    }
    
    private func setBinding() {
        openCalendarButton.isSelectedRelay
            .map { !$0 }
            .bind(to: calendarView.rx.isHidden)
            .disposed(by: disposeBag)
        
        openCalendarButton.isSelectedRelay
            .map { !$0 }
            .bind(to: separatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        goToTodayButton.rx.tap
            .bind(to: goToTodayButtonTap)
            .disposed(by: disposeBag)
        
        previousDateButton.tap
            .withLatestFrom(selectedDate)
            .map { Calendar.current.date(byAdding: .day, value: -1, to: $0) ?? $0 }
            .bind(to: selectedDate)
            .disposed(by: disposeBag)

        nextDateButton.tap
            .withLatestFrom(selectedDate)
            .map { Calendar.current.date(byAdding: .day, value: 1, to: $0) ?? $0 }
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
        
        selectedDate
            .compactMap { [weak self] date -> String? in
                guard let self else { return nil }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatKoreanDate(formatter.string(from: date))
            }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        selectedDate
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                
                let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                if let selection = self.calendarView.selectionBehavior as? UICalendarSelectionSingleDate {
                    selection.setSelected(comps, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        markedDatesRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let dateComponentsArray = self.markedDatesRelay.value.map { date in
                    Calendar.current.dateComponents([.year, .month, .day], from: date)
                }
                
                self.calendarView.reloadDecorations(forDateComponents: dateComponentsArray, animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func formatKoreanDate(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        return outputFormatter.string(from: date)
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate,
                       didSelectDate dateComponents: DateComponents?) {
        guard let comps = dateComponents,
              let date = Calendar.current.date(from: comps) else { return }
        
        selectedDate.accept(date)
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let calendar = Calendar.current
        
        guard let date = calendar.date(from: dateComponents) else { return nil }
        
        let isTarget = markedDatesRelay.value.contains { targetDate in
            calendar.isDate(targetDate, inSameDayAs: date)
        }
        
        if isTarget {
            return .default(color: .red)
        }
        
        return nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        guard let year = calendarView.visibleDateComponents.year,
              let month = calendarView.visibleDateComponents.month else { return }
        
        showNewMonth.accept((year, month))
    }
}

final class OpenCalendarButton: UIButton {
    let isSelectedRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        setUpView()
        setBinding()
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setUpView() {
        var config = UIButton.Configuration.plain()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "calendar", withConfiguration: symbolConfig)
        
        config.image = image
        config.baseBackgroundColor = .lightGray.withAlphaComponent(0.15)
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        self.configuration = config
        self.layer.cornerRadius = 8
    }
    
    private func setBinding() {
        isSelectedRelay
            .subscribe(onNext: { [weak self] isSelected in
                guard let self else { return }
                
                var updatedConfig = self.configuration
                updatedConfig?.baseForegroundColor = isSelected ? .white : .black
                
                UIView.animate(withDuration: 0.3) {
                    self.configuration = updatedConfig
                    self.backgroundColor = isSelected ? .systemBlue : .lightGray.withAlphaComponent(0.15)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func didTap() {
        isSelectedRelay.accept(!isSelectedRelay.value)
    }
}

final class DietEmptyInfoView: UIView {
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "🍽️"
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "이 날의 식단 기록이 없습니다"
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black.withAlphaComponent(0.8)
        label.text = "해당 날짜에 기록된 식단이 없습니다."
        return label
    }()
    private let addDietButton = TitledButton(
        title: "식단 추가하기",
        image: UIImage(systemName: "plus"),
        style: .init(
            backgroundColor: nil,
            titleColor: .white,
            borderColor: nil,
            gradientColors: [.systemBlue, .systemBlue.withAlphaComponent(0.2)]
        )
    )
    
    let buttonTappedRelay: PublishRelay<Void> = .init()
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
        let containerView = BalanceEatContentView()
        
        let mainStackView = UIStackView(arrangedSubviews: [iconLabel, titleLabel, subTitleLabel])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        
        addSubview(containerView)
        containerView.addSubview(mainStackView)
        containerView.addSubview(addDietButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(32)
            make.leading.trailing.equalToSuperview()
        }
        
        addDietButton.snp.makeConstraints { make in
            make.top.equalTo(mainStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.bottom.equalToSuperview().inset(32)
        }
    }
    
    private func setBinding() {
        addDietButton.rx.tap
            .bind(to: buttonTappedRelay)
            .disposed(by: disposeBag)
    }
}
