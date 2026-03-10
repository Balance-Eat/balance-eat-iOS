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
        
        container.register(UserRepositoryProtocol.self) { r in
            UserRepository(context: r.resolveOrFatal(NSManagedObjectContext.self))
        }
        container.register(FoodRepositoryProtocol.self) { _ in FoodRepository() }
        container.register(DietRepositoryProtocol.self) { _ in DietRepository() }
        container.register(ReminderRepositoryProtocol.self) { _ in ReminderRepository() }
        container.register(StatsRepositoryProtocol.self) { _ in StatsRepository() }
        container.register(NotificationRepositoryProtocol.self) { _ in NotificationRepository() }
        
        container.register(UserUseCaseProtocol.self) { r in
            UserUseCase(repository: r.resolveOrFatal(UserRepositoryProtocol.self))
        }
        container.register(FoodUseCaseProtocol.self) { r in
            FoodUseCase(repository: r.resolveOrFatal(FoodRepositoryProtocol.self))
        }
        container.register(DietUseCaseProtocol.self) { r in
            DietUseCase(repository: r.resolveOrFatal(DietRepositoryProtocol.self))
        }
        container.register(StatsUseCaseProtocol.self) { r in
            StatsUseCase(repository: r.resolveOrFatal(StatsRepositoryProtocol.self))
        }
        container.register(NotificationUseCaseProtocol.self) { r in
            NotificationUseCase(repository: r.resolveOrFatal(NotificationRepositoryProtocol.self))
        }
        container.register(ReminderUseCaseProtocol.self) { r in
            ReminderUseCase(repository: r.resolveOrFatal(ReminderRepositoryProtocol.self))
        }
    }
}
