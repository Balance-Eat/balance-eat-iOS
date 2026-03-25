# BalanceEat

> 체중, 골격근량, 체지방률 기반 식단 기록 및 영양 목표 관리 iOS 앱

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-18.0+-blue) ![Xcode](https://img.shields.io/badge/Xcode-26.0+-lightgrey)

[![App Store](https://img.shields.io/badge/App_Store-Download-0D96F6?logo=app-store&logoColor=white)](https://apps.apple.com/us/app/balanceeat/id6754953745)

<br>

## 스크린샷

| 홈 | 식단 내역 | 캘린더 |
|:---:|:---:|:---:|
| <img src="assets/home.png" width="200"> | <img src="assets/diet_list.png" width="200"> | <img src="assets/diet_list_calendar.png" width="200"> |

| 식단 등록 | 음식 검색 | 통계 | 메뉴 |
|:---:|:---:|:---:|:---:|
| <img src="assets/edit_diet.png" width="200"> | <img src="assets/search_food.png" width="200"> | <img src="assets/diet_status.png" width="200"> | <img src="assets/menu.png" width="200"> |

| 목표 설정 | 알림 설정 |
|:---:|:---:|
| <img src="assets/set_target.png" width="200"> | <img src="assets/reminder_list.png" width="200"> |

<br>

## 기술 스택

| 분류 | 사용 기술 |
|------|----------|
| 언어 | Swift |
| UI | UIKit, SnapKit |
| 아키텍처 | MVVM + Clean Architecture + Coordinator Pattern |
| 반응형 | RxSwift, RxCocoa |
| 비동기 | async/await, @MainActor |
| 네트워크 | Alamofire |
| 로컬 저장소 | CoreData, UserDefaults |
| 의존성 주입 | Swinject |
| 푸시 알림 | Firebase Cloud Messaging (FCM) |
| 차트 | DGCharts |
| 테스트 | XCTest |

<br>

## 아키텍처

```mermaid
%%{init: {'theme': 'neutral'}}%%
graph TB
    classDef pres fill:#bfdbfe,stroke:#3b82f6,color:#1e3a5f
    classDef dom  fill:#bbf7d0,stroke:#16a34a,color:#14532d
    classDef dat  fill:#fed7aa,stroke:#ea580c,color:#7c2d12

    subgraph Presentation["📱 Presentation Layer"]
        Coordinator["Coordinator\n(AppCoordinator · MainCoordinator)"]
        VC["ViewControllers\n(Home · DietList · Chart\nMenu · Onboarding · Create)"]
        VM["ViewModels\n(HomeVM · DietListVM · ChartVM\nSearchFoodVM · SetRemindNotiVM...)"]
        DI["DI Container\n(AppDIContainer / Swinject)"]
        Coordinator --> VC
        VC --> VM
        DI -.->|의존성 주입| Coordinator
    end

    subgraph Domain["🏛️ Domain Layer (순수 Swift)"]
        UseCase["UseCases\n(User · Diet · Food\nStats · Reminder · Notification)"]
        RepoProtocol["Repository Protocols\n(UserRepositoryProtocol\nDietRepositoryProtocol 등)"]
        Entity["Entities\n(UserData · DietData · FoodData\nStatsData · ReminderData 등)"]
        UseCase --> RepoProtocol
        UseCase --> Entity
    end

    subgraph Data["🗄️ Data Layer"]
        Repo["Repositories\n(UserRepository · DietRepository\nFoodRepository 등)"]
        DTO["DTOs\n(UserDTO · DietDTO · FoodDTO 등)"]
        Network["Network\n(APIClient · APIEndPoints)"]
        CoreData["CoreData\n(UserCoreData)"]
        Repo --> DTO
        Repo --> Network
        Repo --> CoreData
    end

    VM -->|"UseCase Protocol 호출"| UseCase
    Repo -->|"Protocol 구현"| RepoProtocol
    Repo -->|"Domain 타입 반환"| Entity

    class Coordinator,VC,VM,DI pres
    class UseCase,RepoProtocol,Entity dom
    class Repo,DTO,Network,CoreData dat
```

<br>

## 프로젝트 구조

```
BalanceEat/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Coordinator/                # AppCoordinator, MainCoordinator
├── DI/                         # AppDIContainer (Swinject)
├── Core/
│   └── Presentation/
│       └── Components/         # 공통 UI 컴포넌트
├── Domain/
│   ├── Entities/
│   ├── Models/
│   ├── Repositories/           # Repository Protocols
│   └── UseCases/
├── Data/
│   ├── Network/                # APIClient, APIEndPoints
│   ├── Repository/
│   ├── DTOs/
│   └── CoreData/
├── Presentation/
│   ├── Base/                   # BaseViewController, BaseViewModel
│   ├── Onboarding/
│   ├── Create/                 # 식단 등록, 음식 검색/생성
│   └── Main/
│       ├── Home/
│       ├── List/               # 식단 캘린더
│       ├── Chart/              # 통계
│       └── Menu/               # 사용자 설정, 리마인더
├── Extension/
├── Resources/
└── Utils/
```
