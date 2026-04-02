# BalanceEat

> 체중, 골격근량, 체지방률 기반 식단 기록 및 영양 목표 관리 iOS 앱

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-18.0+-blue) ![Xcode](https://img.shields.io/badge/Xcode-26.0+-lightgrey) [![Beta Deploy](https://github.com/Balance-Eat/balance-eat-iOS/actions/workflows/beta.yml/badge.svg)](https://github.com/Balance-Eat/balance-eat-iOS/actions/workflows/beta.yml)

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

## 주요 기능

| 기능 | 설명 |
|------|------|
| 홈 | 오늘의 칼로리 및 탄·단·지 섭취 현황 요약 |
| 식단 관리 | 아침/점심/저녁/간식별 식단 기록, 월별 캘린더 조회 |
| 음식 검색 | 음식 검색(페이징), 사용자 정의 음식 직접 등록 |
| 통계 | 기간별 영양소 섭취 통계 차트 |
| 리마인더 알림 | 요일·시간대 기반 반복 푸시 알림 |
| 사용자 설정 | 신체 정보, 목표 체중, 활동량, 영양 목표 수정 |
| 온보딩 | 최초 실행 시 튜토리얼 및 신체 정보·목표 설정 플로우 |

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
| CI/CD | GitHub Actions, fastlane, fastlane match |

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
