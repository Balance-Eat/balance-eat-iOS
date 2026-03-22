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

final class ChartViewController: BaseViewController<ChartViewModel> {
    private let refreshControl = UIRefreshControl()
    private let headerView = ChartHeaderView()
    private let statStackView = ChartStatStackView()
    private let periodChangeView = PeriodChangeView()
    private let statsGraphView = StatsGraphView()
    private let achievementRateListView = AchievementRateListView()
    private let analysisInsightView = AnalysisInsightView()

    private var getUserTask: Task<Void, Never>?
    private var getStatsTask: Task<Void, Never>?

    override init(viewModel: ChartViewModel) {
        super.init(viewModel: viewModel)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getStats()
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

                getStatsTask?.cancel()
                getStatsTask = Task {
                    await self.viewModel.getStats(period: period)
                }
            })
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind { [weak self] in
                guard let self else { return }

                getStats(forceRefresh: true)
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
        getUserTask?.cancel()
        getUserTask = Task {
            await viewModel.getUser()
        }
    }

    private func getStats(forceRefresh: Bool = false) {
        let period = headerView.periodRelay.value
        getStatsTask?.cancel()
        getStatsTask = Task {
            await viewModel.getStats(period: period, forceRefresh: forceRefresh)
            refreshControl.endRefreshing()
        }
    }

    deinit {
        getUserTask?.cancel()
        getStatsTask?.cancel()
    }
}
