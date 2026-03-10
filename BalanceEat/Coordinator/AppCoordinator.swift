//
//  AppCoordinator.swift
//  BalanceEat
//
//  Created by 김견 on 3/3/26.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let container: AppDIContainer
    private var mainCoordinator: MainCoordinator?
    private var nav: UINavigationController?

    init(window: UIWindow, container: AppDIContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        let userUseCase = container.container.resolveOrFatal(UserUseCaseProtocol.self)

        switch userUseCase.getUserUUID() {
        case .success:
            showMain()
        case .failure:
            showOnboarding()
        }
    }

    private func showMain() {
        mainCoordinator = MainCoordinator(window: window, container: container)
        mainCoordinator?.start()
    }

    private func showOnboarding() {
        let onboardingVC = OnboardingStartViewController()
        let navigation = UINavigationController(rootViewController: onboardingVC)
        self.nav = navigation

        onboardingVC.onStart = { [weak self, weak navigation] in
            guard let self, let navigation else { return }
            let userUseCase = self.container.container.resolveOrFatal(UserUseCaseProtocol.self)
            let vm = TutorialContentViewModel(userUseCase: userUseCase)
            let nextVC = TutorialContentViewController(viewModel: vm)

            nextVC.onComplete = { [weak self] in
                self?.showMain()
            }

            navigation.setViewControllers([nextVC], animated: true)
        }

        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
}
