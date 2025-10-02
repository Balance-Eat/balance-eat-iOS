//
//  HomeViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: BaseViewController<HomeViewModel> {
    
    private let refreshControl = UIRefreshControl()
    private let welcomeBackgroundView = GradientView()
    
    private lazy var welcomeLabelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        
        let label1 = UILabel()
        label1.text = "안녕하세요, 님!"
        label1.font = .systemFont(ofSize: 24, weight: .bold)
        label1.textColor = .white
        
        let label2 = UILabel()
        label2.text = "오늘도 건강한 하루 되세요 💪"
        label2.font = .systemFont(ofSize: 14, weight: .regular)
        label2.textColor = .white
        
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        
        return stackView
    }()
    
    private let bodyStatusStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var nowBodyStatusCardView: BodyStatusCardView = BodyStatusCardView(
        title: "현재 체성분",
        weight: 0,
        smi: nil,
        fatPercentage: nil
    )
    private lazy var targetBodyStatusCardView: BodyStatusCardView = BodyStatusCardView(
        title: "목표 체성분",
        weight: 0,
        smi: nil,
        fatPercentage: nil,
        isTarget: true
    )
    
    private let todayCalorieView: TodayCalorieView = TodayCalorieView(
        currentCalorie: 0,
        targetCalorie: 0,
        currentCarbohydrate: 0,
        targetCarbohydrate: 0,
        currentProtein: 0,
        targetProtein: 0,
        currentFat: 0,
        targetFat: 0
    )
    
    private let proteinRemindCardView = ProteinReminderCardView(proteinTime: Calendar.current.date(byAdding: .minute, value: 90, to: Date())!)
    
    private lazy var todayAteMealLogListView: MealLogListView = {
        let mealLogs: [MealLogView] = []
        return MealLogListView(mealLogs: mealLogs)
    }()
    
    
    init() {
        let userRepository = UserRepository()
        let userUseCase = UserUseCase(repository: userRepository)
        
        let dietRepository = DietRepository()
        let dietUseCase = DietUseCase(repository: dietRepository)
        
        let vm = HomeViewModel(userUseCase: userUseCase, dietUseCase: dietUseCase)
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDatas()
    }
    
    private func setUpView() {
        scrollView.refreshControl = refreshControl
        
        topContentView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        [welcomeBackgroundView, bodyStatusStackView, todayCalorieView, proteinRemindCardView, todayAteMealLogListView].forEach(mainStackView.addArrangedSubview(_:))
        
        welcomeBackgroundView.addSubview(welcomeLabelStackView)
        welcomeBackgroundView.colors = [
            UIColor.welcomeTitleStartBackground,
            UIColor.welcomeTitleEndBackground
        ]
        
        bodyStatusStackView.addArrangedSubview(nowBodyStatusCardView)
        bodyStatusStackView.addArrangedSubview(targetBodyStatusCardView)
        
        welcomeBackgroundView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        welcomeLabelStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        bodyStatusStackView.snp.makeConstraints { make in
            make.top.equalTo(welcomeBackgroundView.snp.bottom).inset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            
        }
        
        todayCalorieView.snp.makeConstraints { make in
            make.top.equalTo(bodyStatusStackView.snp.bottom).inset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        proteinRemindCardView.snp.makeConstraints { make in
            make.top.equalTo(todayCalorieView.snp.bottom).inset(-40)
            make.leading.trailing.equalToSuperview().inset(20)
//            make.bottom.equalToSuperview().inset(20)
        }
        
        todayAteMealLogListView.snp.makeConstraints { make in
            make.top.equalTo(proteinRemindCardView.snp.bottom).inset(-40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func getDatas() {
        Task {
            await viewModel.getUser()
            await viewModel.getDailyDiet()
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setBinding() {
        viewModel.userResponseRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let self else { return }
                self.updateUIForUserData(user: user)
            })
            .disposed(by: disposeBag)
        
        viewModel.dietResponseRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] dietList in
                guard let self else { return }
                updateUIForDailyDietDate(dietList: dietList)
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }
                getDatas()
            }
            .disposed(by: disposeBag)
        
        Observable.merge(nowBodyStatusCardView.goToEditTapRelay.asObservable(), targetBodyStatusCardView.goToEditTapRelay.asObservable())
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    return
                }
                guard let userData = viewModel.userResponseRelay.value else {
                    return
                }
                                
                navigationController?.pushViewController(EditTargetViewController(userData: userData), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUIForUserData(user: UserData) {
        if let label = (welcomeLabelStackView.arrangedSubviews.first as? UILabel) {
            label.text = "안녕하세요, \(user.name)님!"
        }

        nowBodyStatusCardView.update(
            weight: user.weight,
            smi: user.smi,
            fatPercentage: user.fatPercentage
        )

        let smiDiff: Double? = {
            if let target = user.targetSmi, let current = user.smi {
                return target - current
            }
            return nil
        }()

        let fatDiff: Double? = {
            if let target = user.targetFatPercentage, let current = user.fatPercentage {
                return target - current
            }
            return nil
        }()

        targetBodyStatusCardView.update(
            weight: user.targetWeight - user.weight,
            smi: smiDiff,
            fatPercentage: fatDiff
        )

    }
    
    private func updateUIForDailyDietDate(dietList: [DietData]) {
        let currentCalorie = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.calories } }
        let currentCarbonhydrate = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.carbohydrates } }
        let currentProtein = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.protein } }
        let currentFat = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.fat } }
        
        todayCalorieView.update(
            currentCalorie: Int(currentCalorie),
            targetCalorie: viewModel.userResponseRelay.value?.targetCalorie ?? 0,
            currentCarbohydrate: Int(currentCarbonhydrate),
            targetCarbohydrate: Int(viewModel.userResponseRelay.value?.targetCarbohydrates ?? 0),
            currentProtein: Int(currentProtein),
            targetProtein: Int(viewModel.userResponseRelay.value?.targetProtein ?? 0),
            currentFat: Int(currentFat),
            targetFat: Int(viewModel.userResponseRelay.value?.targetFat ?? 0)
        )
        
        var mealLogs: [MealLogView] = []
        dietList.forEach { diet in
            let mealLogView = MealLogView(
                icon: UIImage(systemName: diet.mealType.icon),
                title: diet.mealType.title,
                ateTime: extractHourMinute(from: diet.consumedAt) ?? "",
                consumedCalories: diet.items.reduce(0) { $0 + Int($1.calories) },
                foodDatas: diet.items
            )
            
            mealLogs.append(mealLogView)
        }
        todayAteMealLogListView.updateMealLogs(mealLogs)
    }
    
    func extractHourMinute(from dateString: String) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        guard let date = isoFormatter.date(from: dateString) else { return nil }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return timeFormatter.string(from: date)
    }
}

final class MealLogListView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 식사 기록"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .bodyStatusCardNumber
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private var mealLogs: [MealLogView] = []
    
    init(mealLogs: [MealLogView]) {
        super.init(frame: .zero)
        self.mealLogs = mealLogs
        setupView()
        configureStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        updateTitleVisibility()
    }
    
    private func setupView() {
        addSubview(titleLabel)
        addSubview(stackView)
        
        self.backgroundColor = .clear
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func configureStackView() {
        for mealLog in mealLogs {
            stackView.addArrangedSubview(mealLog)
        }
    }
    
    func updateMealLogs(_ logs: [MealLogView]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.mealLogs = logs
        configureStackView()
        updateTitleVisibility()
    }
    
    private func updateTitleVisibility() {
            titleLabel.isHidden = mealLogs.isEmpty
        }
}
