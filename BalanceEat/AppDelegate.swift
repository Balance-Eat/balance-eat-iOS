//
//  AppDelegate.swift
//  BalanceEat
//
//  Created by 김견 on 7/9/25.
//

import UIKit
import CoreData
import FirebaseCore
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    private var notificationUseCase: NotificationUseCaseProtocol {
        AppDIContainer.shared.container.resolveOrFatal(NotificationUseCaseProtocol.self)
    }
    private var userUseCase: UserUseCaseProtocol {
        AppDIContainer.shared.container.resolveOrFatal(UserUseCaseProtocol.self)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOption
            ) {
                granted,
                error in
                
                let userDefaultsManager = UserDefaultsManager.shared
                
                #if DEBUG
                print("didfinishLaunchingWithOptions: fcm토큰: \(userDefaultsManager.getString(forKey: .agentId))")
                #endif
                
                userDefaultsManager.set(granted, forKey: .pushNotificationEnabled)
                if let error {
                    #if DEBUG
                    print("permission error: \(error)")
                    #endif
                } else if !userDefaultsManager.getBool(forKey: .saveToNotificationServerSuccess) {
                    let token = userDefaultsManager.getString(forKey: .agentId)
                    if token == "" { return }
                    let notificationRequestDTO = NotificationRequestDTO(
                        agentId: token,
                        osType: "IOS",
                        deviceName: UIDevice.current.name,
                        isActive: granted
                    )
                    
                    Task {
                        let createNotificationResult = await self.notificationUseCase.createNotification(notificationRequestDTO: notificationRequestDTO, userId: self.getUserId())
                        
                        switch createNotificationResult {
                        case .success(let notificationResponseDTO):
                            #if DEBUG
                            print("create noti success: \(notificationResponseDTO)")
                            #endif
                            userDefaultsManager.set(true, forKey: .saveToNotificationServerSuccess)
                        case .failure(let error):
                            if error.description.contains("NOTIFICATION_DEVICE_ALREADY_EXISTS") {
                                userDefaultsManager.set(true, forKey: .saveToNotificationServerSuccess)
                            }
                            #if DEBUG
                            print("create noti failed : \(error.description)")
                            #endif
                        }
                    }
                    
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        print("deviceToken: \(deviceToken)")
        #endif
        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BalanceEat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private func getUserId() -> String {
        switch userUseCase.getUserId() {
        case .success(let userId): return String(userId)
        case .failure(_):
            return ""
        }
    }
}

// Cloud Messaging
extension AppDelegate: MessagingDelegate {
    
    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("didReceiveRegistrationToken fcm토큰: \(fcmToken ?? "")")
        #endif
        let userDefaultsManager = UserDefaultsManager.shared
        
        if userDefaultsManager.getBool(forKey: .saveToNotificationServerSuccess) && userDefaultsManager.getString(forKey: .agentId) == fcmToken {
            return
        }
        
        let permissionForNotification = userDefaultsManager.getBool(forKey: .pushNotificationEnabled)
        
        if userDefaultsManager.getString(forKey: .agentId) != fcmToken {
            let notificationRequestDTO = NotificationRequestDTO(
                agentId: fcmToken ?? "",
                osType: "IOS",
                deviceName: UIDevice.current.name,
                isActive: permissionForNotification
            )
            
            Task {
                let createNotificationResult = await self.notificationUseCase.createNotification(notificationRequestDTO: notificationRequestDTO, userId: self.getUserId())
                
                switch createNotificationResult {
                case .success:
                    break
                case .failure(let error):
                    #if DEBUG
                    print("알림 기기 등록 실패: \(error.description)")
                    #endif
                }
            }
        }
        if let fcmToken {
            userDefaultsManager.set(fcmToken, forKey: .agentId)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        #if DEBUG
        print("FCM registration failed with error: \(error.localizedDescription)")
        #endif
    }
}

// User Notifications [AKA InApp Notification]
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 푸시 메시지가 앱이 켜져있을 때 나올 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            #if DEBUG
            print("messageID: \(messageID)")
            #endif
        }

        completionHandler([[.banner, .badge, .sound]])
    }
    
    // 푸시 알림 받았을 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            #if DEBUG
            print("messageID: \(messageID)")
            #endif
        }
        NotificationCenter.default.post(name: .pushNotificationReceived, object: nil, userInfo: userInfo)

        completionHandler()
    }
}

extension Notification.Name {
    static let pushNotificationReceived = Notification.Name("pushNotificationReceived")
}
