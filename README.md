# BalanceEat

> 체중, 골격근량, 체지방률 기반 식단 기록 및 영양 목표 관리 iOS 앱

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-18.0+-blue) ![Xcode](https://img.shields.io/badge/Xcode-26.0+-lightgrey)

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

<br>

## 아키텍처

```
Presentation
├── ViewController (BaseViewController<VM> 상속)
├── ViewModel (BaseViewModel 상속, RxSwift Relay + async/await)
└── Coordinator (화면 전환 및 의존성 주입 담당)

Domain
├── Entities
├── UseCases (Protocol + 구현체)
└── Repository Protocols

Data
├── Repositories (구현체)
├── DTOs
└── Network (APIClient, APIEndPoints)
```

**Coordinator Pattern**
- `AppCoordinator` → 온보딩 / 메인 플로우 분기
- 각 `ViewController`는 `onXxx: (() -> Void)?` 클로저로 화면 전환을 Coordinator에 위임
- `ViewController`에서 `AppDIContainer`를 직접 참조하지 않고, Coordinator가 의존성을 주입

**RxSwift + async/await 혼용 전략**
- `UseCase / Repository` 레이어: `async/await` — 일회성 비동기 작업에 적합
- `ViewModel`: `@MainActor async` 함수로 네트워크 호출 후 결과를 `Relay`에 저장
- `ViewController`: `Task { await viewModel.xxx() }` + RxSwift 구독으로 UI 업데이트

<br>

## 기술적 의사결정

**RxSwift + async/await 혼용**

RxSwift는 버튼 탭, 텍스트 변경처럼 지속적인 이벤트 스트림에, async/await는 네트워크 호출처럼 일회성 비동기 작업에 적합합니다. 역할이 다르기 때문에 두 기술을 병행했습니다. ViewModel의 `@MainActor async` 함수가 네트워크 결과를 Relay에 저장하고, ViewController는 Relay를 구독해 UI를 업데이트하는 방식으로 레이어를 분리했습니다.

**Clean Architecture + Swinject DI**

UseCase와 Repository를 프로토콜로 분리하면 Mock 객체로 교체가 가능해 단위 테스트를 작성할 수 있습니다. 실제로 `MockUserUseCase`, `MockDietUseCase`를 작성해 네트워크 없이 ViewModel 로직을 검증했습니다. Swinject는 의존성 등록과 주입을 한 곳(`AppDIContainer`)에서 관리해 ViewController가 직접 의존성을 생성하지 않도록 했습니다.

<br>

## 트러블슈팅

**RxSwift 구독 누적으로 인한 메모리 누수**

`viewWillAppear`에서 바인딩을 설정하면 화면이 나타날 때마다 구독이 쌓이는 문제가 있었습니다. 별도의 `presentationBag = DisposeBag()`을 도입해 화면이 나타날 때마다 이전 구독을 해제하도록 수정했습니다.

**FCM 토큰 갱신 시 기기 중복 등록 문제**

앱 재설치나 토큰 갱신 시 서버에 동일 기기가 중복 등록될 수 있었습니다. `UserDefaults`에 저장된 이전 토큰과 비교해 변경된 경우에만 서버에 등록 요청을 보내고, `saveToNotificationServerSuccess` 플래그로 중복 호출을 방지했습니다.

<br>

## 프로젝트 구조

```
BalanceEat/
├── App/                        # AppDelegate, SceneDelegate
├── Coordinator/                # AppCoordinator, MainCoordinator
├── DI/                         # AppDIContainer (Swinject)
├── Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Interfaces/             # Repository Protocols
├── Data/
│   ├── Network/                # APIClient, APIEndPoints
│   ├── Repositories/
│   └── DTOs/
└── Presentation/
    ├── Base/                   # BaseViewController, BaseViewModel
    ├── Onboarding/
    └── Main/
        ├── Home/
        ├── List/               # 식단 캘린더
        ├── Chart/              # 통계
        └── Menu/               # 사용자 설정, 리마인더
```
