//
//  AppDIContainer.swift
//  BalanceEat
//
//  Created by 김견 on 3/3/26.
//

import UIKit
import Swinject
import CoreData

extension Resolver {
    func resolveOrFatal<Service>(_ serviceType: Service.Type) -> Service {
        guard let service = resolve(serviceType) else {
            fatalError("\(serviceType) is not registered in the DI container")
        }
        return service
    }
}

final class AppDIContainer {
    static let shared = AppDIContainer()
    let container = Container()
    
    private init () {
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(NSManagedObjectContext.self) { _ in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("AppDelegate is not of expected type")
            }
            return appDelegate.persistentContainer.viewContext
        }.inObjectScope(.container)
        
        container.register(UserRepository.self) { r in
            DefaultUserRepository(context: r.resolveOrFatal(NSManagedObjectContext.self))
        }
        container.register(FoodRepository.self) { _ in DefaultFoodRepository() }
        container.register(DietRepository.self) { _ in DefaultDietRepository() }
        container.register(ReminderRepository.self) { _ in DefaultReminderRepository() }
        container.register(StatsRepository.self) { _ in DefaultStatsRepository() }
        container.register(NotificationRepository.self) { _ in DefaultNotificationRepository() }

        container.register(UserUseCaseProtocol.self) { r in
            UserUseCase(repository: r.resolveOrFatal(UserRepository.self))
        }
        container.register(FoodUseCaseProtocol.self) { r in
            FoodUseCase(repository: r.resolveOrFatal(FoodRepository.self))
        }
        container.register(DietUseCaseProtocol.self) { r in
            DietUseCase(repository: r.resolveOrFatal(DietRepository.self))
        }
        container.register(StatsUseCaseProtocol.self) { r in
            StatsUseCase(repository: r.resolveOrFatal(StatsRepository.self))
        }
        container.register(NotificationUseCaseProtocol.self) { r in
            NotificationUseCase(repository: r.resolveOrFatal(NotificationRepository.self))
        }
        container.register(ReminderUseCaseProtocol.self) { r in
            ReminderUseCase(repository: r.resolveOrFatal(ReminderRepository.self))
        }
    }
}
