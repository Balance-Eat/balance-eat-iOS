//
//  MainCoordinator.swift
//  BalanceEat
//
//  Created by 김견 on 3/3/26.
//

import UIKit

final class MainCoordinator {
    private let window: UIWindow
    private let container: AppDIContainer
    private var nav: UINavigationController?

    init(window: UIWindow, container: AppDIContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        let mainVC = MainViewController(viewControllers: [
            buildHomeViewController(),
            buildDietListViewController(),
            buildChartViewController(),
            buildMenuViewController()
        ])
        let navigation = UINavigationController(rootViewController: mainVC)
        self.nav = navigation
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }

    // MARK: - Tab ViewControllers

    private func buildHomeViewController() -> HomeViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let dietUseCase = container.container.resolveOrFatal(DietUseCaseProtocol.self)
        let vm = HomeViewModel(userUseCase: userUseCase, dietUseCase: dietUseCase)
        let vc = HomeViewController(viewModel: vm)

        vc.onGoToDiet = { [weak self] dietDatas, date in
            guard let self else { return }
            let createVC = buildCreateDietViewController(dietDatas: dietDatas, date: date)
            nav?.pushViewController(createVC, animated: true)
        }

        vc.onAddDiet = { [weak self] in
            guard let self else { return }
            let createVC = buildCreateDietViewController(dietDatas: [], date: Date())
            nav?.pushViewController(createVC, animated: true)
        }

        vc.onEditTarget = { [weak self] userData in
            guard let self else { return }
            let editVC = buildEditTargetViewController(userData: userData)
            nav?.pushViewController(editVC, animated: true)
        }

        return vc
    }

    private func buildDietListViewController() -> DietListViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let dietUseCase = container.container.resolveOrFatal(DietUseCaseProtocol.self)
        let vm = DietListViewModel(userUseCase: userUseCase, dietUseCase: dietUseCase)
        let vc = DietListViewController(viewModel: vm)

        vc.onGoToDiet = { [weak self] dietDatas, date in
            guard let self else { return }
            let createVC = buildCreateDietViewController(dietDatas: dietDatas, date: date)
            nav?.pushViewController(createVC, animated: true)
        }

        return vc
    }

    private func buildChartViewController() -> ChartViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let statsUseCase = container.container.resolveOrFatal(StatsUseCaseProtocol.self)
        let vm = ChartViewModel(userUseCase: userUseCase, statsUseCase: statsUseCase)
        return ChartViewController(viewModel: vm)
    }

    private func buildMenuViewController() -> MenuViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let notificationUseCase = container.container.resolveOrFatal(NotificationUseCaseProtocol.self)
        let vm = MenuViewModel(userUseCase: userUseCase, notificationUseCase: notificationUseCase)
        let vc = MenuViewController(viewModel: vm)

        vc.onEditBasicInfo = { [weak self] userData in
            guard let self else { return }
            let editVC = buildEditBasicInfoViewController(userData: userData)
            nav?.pushViewController(editVC, animated: true)
        }

        vc.onEditTarget = { [weak self] userData in
            guard let self else { return }
            let editVC = buildEditTargetViewController(userData: userData)
            nav?.pushViewController(editVC, animated: true)
        }

        vc.onEditTargetTypeAndActivityLevel = { [weak self] userData in
            guard let self else { return }
            let editVC = buildEditTargetTypeAndActivityLevelViewController(userData: userData)
            nav?.pushViewController(editVC, animated: true)
        }

        vc.onSetRemindNoti = { [weak self] in
            guard let self else { return }
            let remindVC = buildSetRemindNotiViewController()
            nav?.pushViewController(remindVC, animated: true)
        }

        return vc
    }

    // MARK: - Child ViewControllers

    private func buildCreateDietViewController(dietDatas: [DietData], date: Date) -> CreateDietViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let dietUseCase = container.container.resolveOrFatal(DietUseCaseProtocol.self)
        let vm = CreateDietViewModel(dietUseCase: dietUseCase, userUseCase: userUseCase, dietDatas: dietDatas, date: date)
        let vc = CreateDietViewController(viewModel: vm)

        vc.makeSearchFoodViewController = { [weak self] in
            self?.buildSearchFoodViewController()
        }

        return vc
    }

    private func buildSearchFoodViewController() -> SearchFoodViewController {
        let foodUseCase = container.container.resolveOrFatal(FoodUseCaseProtocol.self)
        let vm = SearchFoodViewModel(foodUseCase: foodUseCase)
        let vc = SearchFoodViewController(viewModel: vm)

        vc.makeCreateFoodViewController = { [weak self] in
            self?.buildCreateFoodViewController()
        }

        return vc
    }

    private func buildCreateFoodViewController() -> CreateFoodViewController {
        let foodUseCase = container.container.resolveOrFatal(FoodUseCaseProtocol.self)
        let vm = CreateFoodViewModel(foodUseCase: foodUseCase)
        return CreateFoodViewController(viewModel: vm)
    }

    private func buildEditBasicInfoViewController(userData: UserData) -> EditBasicInfoViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let vm = EditBasicInfoViewModel(userData: userData, userUseCase: userUseCase)
        return EditBasicInfoViewController(viewModel: vm)
    }

    private func buildEditTargetViewController(userData: UserData) -> EditTargetViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let vm = EditTargetViewModel(userData: userData, userUseCase: userUseCase)
        return EditTargetViewController(viewModel: vm)
    }

    private func buildEditTargetTypeAndActivityLevelViewController(userData: UserData) -> EditTargetTypeAndActivityLevelViewController {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let vm = EditTargetTypeAndActivityLevelViewModel(userData: userData, userUseCase: userUseCase)
        let vc = EditTargetTypeAndActivityLevelViewController(viewModel: vm)

        vc.onGoToNutritionSetting = { [weak self, weak vm] in
            guard let self, let vm else { return }
            let nutritionVC = EditNutritionViewController(vm: vm)
            self.nav?.pushViewController(nutritionVC, animated: true)
        }

        return vc
    }

    private func buildSetRemindNotiViewController() -> SetRemindNotiViewController {
        let notificationUseCase = container.container.resolveOrFatal(NotificationUseCaseProtocol.self)
        let reminderUseCase = container.container.resolveOrFatal(ReminderUseCaseProtocol.self)
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)
        let vm = SetRemindNotiViewModel(notificationUseCase: notificationUseCase, reminderUseCase: reminderUseCase, userUseCase: userUseCase)
        return SetRemindNotiViewController(viewModel: vm)
    }
}
