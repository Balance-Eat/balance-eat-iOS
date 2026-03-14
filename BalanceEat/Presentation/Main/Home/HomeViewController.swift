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
        
        Observable.combineLatest(viewModel.userNowBodyStatusRelay, viewModel.userTargetBodyStatusRelay)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bodyStatus, targetBodyStatus in
                guard let self else { return }
                            
                nowBodyStatusCardView.weightRelay.accept(bodyStatus.0)
                nowBodyStatusCardView.smiRelay.accept(bodyStatus.1)
                nowBodyStatusCardView.fatPercentageRelay.accept(bodyStatus.2)
                
                let weightDiff = targetBodyStatus.0 - bodyStatus.0
                
                let smiDiff: Double? = {
                    if let target = targetBodyStatus.1, let current = bodyStatus.1 {
                        return target - current
                    }
                    return nil
                }()

                let fatDiff: Double? = {
                    if let target = targetBodyStatus.2, let current = bodyStatus.2 {
                        return target - current
                    }
                    return nil
                }()
                
                targetBodyStatusCardView.weightRelay.accept(weightDiff)
                targetBodyStatusCardView.smiRelay.accept(smiDiff)
                targetBodyStatusCardView.fatPercentageRelay.accept(fatDiff)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    private func updateUIForDailyDietDate(dietList: [DietData]) {
        let currentCalorie = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.calories } }
        let currentCarbohydrate = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.carbohydrates } }
        let currentProtein = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.protein } }
        let currentFat = dietList.reduce(0) { $0 + $1.items.reduce(0) { $0 + $1.fat } }
        
        todayCalorieView.update(
            currentCalorie: Int(currentCalorie),
            targetCalorie: Int(viewModel.userResponseRelay.value?.targetCalorie ?? 0),
            currentCarbohydrate: Int(currentCarbohydrate),
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
                ateTime: viewModel.formatConsumedTime(diet.consumedAt),
                consumedCalories: diet.items.reduce(0) { $0 + Int($1.calories) },
                foodDatas: diet.items
            )
            
            mealLogs.append(mealLogView)
        }
        todayAteMealLogListView.mealLogsRelay.accept(mealLogs)
    }
}

final class MealLogListView: UIView {
    
    private let goToDietButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "식단 상세보기"
        config.titleAlignment = .leading
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = .systemFont(ofSize: 17, weight: .bold)
            attr.foregroundColor = .black
            return attr
        }
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        config.image = UIImage(systemName: "chevron.right", withConfiguration: imageConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        let button = UIButton(configuration: config)
        button.tintColor = .black
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private let dietEmptyInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "오늘의 식단 기록이 없습니다"
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
    
    private lazy var dietEmptyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dietEmptyInfoLabel, addDietButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    let mealLogsRelay = BehaviorRelay<[MealLogView]>(value: [])
    let goToDietButtonTapRelay = PublishRelay<Void>()
    let addDietButtonTapRelay = PublishRelay<Void>()
    private let logIsEmptyRelay = BehaviorRelay<Bool>(value: false)
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
        backgroundColor = .clear
        
        [goToDietButton, stackView, dietEmptyStackView].forEach(addSubview)
        
        goToDietButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(goToDietButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
         
        dietEmptyStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
    private func setBinding() {
        mealLogsRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] logs in
                self?.configureStackView(with: logs)
            })
            .disposed(by: disposeBag)
        
        mealLogsRelay
            .map { $0.isEmpty }
            .bind(to: logIsEmptyRelay)
            .disposed(by: disposeBag)
        
        logIsEmptyRelay
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                self?.toggleEmptyState(isEmpty: isEmpty)
            })
            .disposed(by: disposeBag)
        
        goToDietButton.rx.tap
            .bind(to: goToDietButtonTapRelay)
            .disposed(by: disposeBag)
        
        addDietButton.rx.tap
            .bind(to: addDietButtonTapRelay)
            .disposed(by: disposeBag)
    }
    
    private func configureStackView(with mealLogs: [MealLogView]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            mealLogs.forEach { log in
                
                stackView.addArrangedSubview(log)
            }
    }
    
    private func toggleEmptyState(isEmpty: Bool) {
        goToDietButton.isHidden = isEmpty
        stackView.isHidden = isEmpty
        dietEmptyStackView.isHidden = !isEmpty
        
        if isEmpty {
            dietEmptyStackView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().inset(24)
            }
        } else {
            dietEmptyStackView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
            }
        }
    }
}

