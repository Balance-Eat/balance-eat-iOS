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

final class HomeViewController: BaseViewController<HomeViewModel> {
    
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
        title: "현재 체성분"
    )
    private lazy var targetBodyStatusCardView: BodyStatusCardView = BodyStatusCardView(
        title: "목표 체성분",
        isTarget: true
    )
    
    var onGoToDiet: (([DietData], Date) -> Void)?
    var onAddDiet: (() -> Void)?
    var onEditTarget: ((UserData) -> Void)?

    private var dataFetchTask: Task<Void, Never>?

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
    
    private let proteinRemindCardView = ProteinReminderCardView(proteinTime: Calendar.current.date(byAdding: .minute, value: 90, to: Date()) ?? Date())
    
    private let todayAteMealLogListView = MealLogListView()
    
    
    override init(viewModel: HomeViewModel) {
        super.init(viewModel: viewModel)
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

        todayCalorieView.isAccessibilityElement = true
        todayCalorieView.accessibilityLabel = "오늘의 칼로리 및 영양소 섭취 현황"

        nowBodyStatusCardView.isAccessibilityElement = true
        nowBodyStatusCardView.accessibilityLabel = "현재 체성분 정보"

        targetBodyStatusCardView.isAccessibilityElement = true
        targetBodyStatusCardView.accessibilityLabel = "목표 체성분 정보"

        topContentView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        [welcomeBackgroundView, bodyStatusStackView, todayCalorieView, todayAteMealLogListView].forEach(mainStackView.addArrangedSubview(_:))
        
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
        
        todayAteMealLogListView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func getDatas() {
        dataFetchTask?.cancel()
        dataFetchTask = Task {
            await viewModel.getUser()
            await viewModel.getDailyDiet()
            refreshControl.endRefreshing()
        }
    }

    deinit {
        dataFetchTask?.cancel()
    }
    
    private func setBinding() {
        viewModel.dietResponseRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] dietList in
                guard let self else { return }
                var mealLogs: [MealLogView] = []
                dietList.forEach { diet in
                    let mealLogView = MealLogView(
                        icon: UIImage(systemName: diet.mealType.icon),
                        title: diet.mealType.title,
                        ateTime: self.viewModel.formatConsumedTime(diet.consumedAt),
                        consumedCalories: diet.items.reduce(0) { $0 + Int($1.calories) },
                        foodDatas: diet.items
                    )
                    mealLogs.append(mealLogView)
                }
                todayAteMealLogListView.mealLogsRelay.accept(mealLogs)
            })
            .disposed(by: disposeBag)

        viewModel.dailyNutritionSummaryRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] achievement in
                guard let self else { return }
                let user = viewModel.userResponseRelay.value
                let targetCalorie = user?.targetCalorie ?? 0
                let targetCarbohydrate = user?.targetCarbohydrates ?? 0
                let targetProtein = user?.targetProtein ?? 0
                let targetFat = user?.targetFat ?? 0
                todayCalorieView.update(
                    currentCalorie: Int(achievement.calorieRate * targetCalorie),
                    targetCalorie: Int(targetCalorie),
                    currentCarbohydrate: Int(achievement.carbohydrateRate * targetCarbohydrate),
                    targetCarbohydrate: Int(targetCarbohydrate),
                    currentProtein: Int(achievement.proteinRate * targetProtein),
                    targetProtein: Int(targetProtein),
                    currentFat: Int(achievement.fatRate * targetFat),
                    targetFat: Int(targetFat)
                )
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
                guard let self else { return }
                guard let userData = viewModel.userResponseRelay.value else { return }
                onEditTarget?(userData)
            })
            .disposed(by: disposeBag)

        todayAteMealLogListView.goToDietButtonTapRelay
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                onGoToDiet?(viewModel.dietResponseRelay.value ?? [], Date())
            })
            .disposed(by: disposeBag)

        todayAteMealLogListView.addDietButtonTapRelay
            .subscribe(onNext: { [weak self] in
                self?.onAddDiet?()
            })
            .disposed(by: disposeBag)

        viewModel.userNameRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] name in
                guard let self else { return }
                if let label = (welcomeLabelStackView.arrangedSubviews.first as? UILabel) {
                    label.text = "안녕하세요, \(name)님!"
                }
            })
            .disposed(by: disposeBag)

        viewModel.userNowBodyStatusRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bodyStatus in
                guard let self else { return }
                nowBodyStatusCardView.weightRelay.accept(bodyStatus.0)
                nowBodyStatusCardView.smiRelay.accept(bodyStatus.1)
                nowBodyStatusCardView.fatPercentageRelay.accept(bodyStatus.2)
            })
            .disposed(by: disposeBag)

        viewModel.bodyStatusDiffRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] diff in
                guard let self else { return }
                targetBodyStatusCardView.weightRelay.accept(diff.weightDiff)
                targetBodyStatusCardView.smiRelay.accept(diff.smiDiff)
                targetBodyStatusCardView.fatPercentageRelay.accept(diff.fatDiff)
            })
            .disposed(by: disposeBag)
    }
}

