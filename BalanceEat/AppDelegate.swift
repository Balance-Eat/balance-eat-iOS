//
//  AppDelegate.swift
//  BalanceEat
//
//  Created by 김견 on 7/9/25.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private static let gcmMessageIDKey = "gcm.message_id"

    private lazy var notificationUseCase: NotificationUseCaseProtocol = AppDIContainer.shared.container.resolveOrFatal(NotificationUseCaseProtocol.self)
    private lazy var userUseCase: UserUseCaseProtocol = AppDIContainer.shared.container.resolveOrFatal(UserUseCaseProtocol.self)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        requestNotificationAuthorization()
        application.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        print("deviceToken: \(deviceToken)")
        #endif
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BalanceEat")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                #if DEBUG
                assertionFailure("CoreData 로드 실패: \(error), \(error.userInfo)")
                #endif
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                #if DEBUG
                let nserror = error as NSError
                print("CoreData 저장 실패: \(nserror), \(nserror.userInfo)")
                #endif
            }
        }
    }
}

// MARK: - Notification Registration

private extension AppDelegate {
    func requestNotificationAuthorization() {
        let deviceName = UIDevice.current.name
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            UserDefaultsManager.shared.set(granted, forKey: .pushNotificationEnabled)

            if let error {
                #if DEBUG
                print("permission error: \(error)")
                #endif
                return
            }

            self?.registerNotificationIfNeeded(deviceName: deviceName, isActive: granted)
        }
    }

    func registerNotificationIfNeeded(token: String? = nil, deviceName: String? = nil, isActive: Bool? = nil) {
        let userDefaultsManager = UserDefaultsManager.shared
        let fcmToken = token ?? userDefaultsManager.getString(forKey: .agentId)
        guard !fcmToken.isEmpty else { return }

        let alreadySaved = userDefaultsManager.getBool(forKey: .saveToNotificationServerSuccess)
        let tokenUnchanged = userDefaultsManager.getString(forKey: .agentId) == fcmToken
        if alreadySaved && tokenUnchanged { return }

        let request = NotificationCreateRequest(
            agentId: fcmToken,
            osType: "IOS",
            deviceName: deviceName ?? UIDevice.current.name,
            isActive: isActive ?? userDefaultsManager.getBool(forKey: .pushNotificationEnabled)
        )

        Task { [weak self] in
            guard let self else { return }
            guard let userId = self.getUserId() else { return }
            let result = await self.notificationUseCase.createNotification(request: request, userId: userId)

            switch result {
            case .success:
                userDefaultsManager.set(fcmToken, forKey: .agentId)
                userDefaultsManager.set(true, forKey: .saveToNotificationServerSuccess)
            case .failure(let error):
                if case .conflict = error {
                    userDefaultsManager.set(true, forKey: .saveToNotificationServerSuccess)
                }
                #if DEBUG
                print("알림 기기 등록 실패: \(error.description)")
                #endif
            }
        }
    }

    func getUserId() -> String? {
        switch userUseCase.getUserId() {
        case .success(let userId): return String(userId)
        case .failure: return nil
        }
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("didReceiveRegistrationToken fcm토큰: \(fcmToken ?? "")")
        #endif

        guard let fcmToken else { return }
        registerNotificationIfNeeded(token: fcmToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        #if DEBUG
        print("FCM registration failed with error: \(error.localizedDescription)")
        #endif
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        #if DEBUG
        if let messageID = notification.request.content.userInfo[Self.gcmMessageIDKey] {
            print("messageID: \(messageID)")
        }
        #endif
        completionHandler([[.banner, .badge, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        #if DEBUG
        if let messageID = userInfo[Self.gcmMessageIDKey] {
            print("messageID: \(messageID)")
        }
        #endif
        NotificationCenter.default.post(name: .pushNotificationReceived, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

extension Notification.Name {
    static let pushNotificationReceived = Notification.Name("pushNotificationReceived")
}
