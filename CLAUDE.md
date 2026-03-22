# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 빌드 및 테스트 명령어

```bash
# 전체 테스트 실행 (시뮬레이터)
xcodebuild test -project BalanceEat.xcodeproj -scheme BalanceEat -destination 'platform=iOS Simulator,name=iPhone 16'

# 특정 테스트 클래스만 실행
xcodebuild test -project BalanceEat.xcodeproj -scheme BalanceEat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BalanceEatTests/SearchFoodViewModelTests

# TestFlight 배포 (fastlane)
fastlane beta
```

## 아키텍처

MVVM + Clean Architecture + Coordinator Pattern.

### 레이어 구조

```
Domain/
├── Entities/          # 순수 Swift 모델 (UserData, DietData, FoodData 등)
├── Repositories/      # Repository 프로토콜 — 파일명 XxxRepositoryProtocol.swift, protocol 이름은 XxxRepository
└── UseCases/          # UseCase 구현체 + XxxUseCaseProtocol

Data/
├── Repository/        # DefaultXxxRepository (프로토콜 구현체)
├── DTOs/              # Codable 네트워크/코어데이터 모델
├── Network/           # APIClient, APIEndPoints
└── CoreData/          # UserCoreData (로컬 저장)

Presentation/
├── Base/              # BaseViewController<VM>, BaseViewModel
├── Coordinator/       # AppCoordinator, MainCoordinator
├── DI/                # AppDIContainer (Swinject)
├── Main/              # Home, List(캘린더), Chart(통계), Menu(설정/알림)
├── Create/            # 식단 등록, 음식 검색/생성
└── Onboarding/        # 튜토리얼, 신체정보/목표 설정
```

### 핵심 패턴

**BaseViewController / BaseViewModel**
- 모든 VC는 `BaseViewController<VM: BaseViewModel>` 서브클래스
- `BaseViewModel`: `loadingRelay`, `toastMessageRelay`, `disposeBag` 제공
- `BaseViewController`: `scrollView`, `topContentView`, `mainStackView`, `loadingView` 제공; 서브클래스 `init(viewModel:)`에 반드시 `override` 키워드 필요

**Coordinator Pattern**
- `AppCoordinator` → 온보딩 / 메인 플로우 분기
- `MainCoordinator`: `buildXxx()` 메서드로 VC 생성, DI 주입
- VC 화면 전환은 `onXxx: (() -> Void)?` 클로저로 Coordinator에 위임
- VC에서 `AppDIContainer.shared` 직접 참조 금지

**DI (Swinject)**
- `AppDIContainer.shared.container`에 모든 의존성 등록
- `Resolver.resolveOrFatal(_:)` 헬퍼 사용 (`register` 클로저의 `r`은 `Resolver` 타입)
- Repository: `XxxRepository.self`(Protocol 접미사 없는 프로토콜)를 키로 등록 → `container.register(FoodRepository.self) { _ in DefaultFoodRepository() }`
- UseCase: `XxxUseCaseProtocol.self`를 키로 등록 → `container.register(FoodUseCaseProtocol.self) { r in FoodUseCase(...) }`

**RxSwift + async/await 혼용**
- UseCase/Repository: `async/await`
- ViewModel: `@MainActor async` 함수로 API 호출 → 결과를 `BehaviorRelay`/`PublishRelay`에 저장
- ViewController: `Task { await viewModel.xxx() }` + RxSwift 구독으로 UI 업데이트
- `Task` 프로퍼티(예: `fetchTask`)를 저장해 두고 `cancel()` → `deinit`에서 취소

**네트워크**
- `APIClient.request<T: Decodable>()` / `requestVoid()` 두 가지
- 에러 파싱: `BaseResponse<EmptyData>` → `ErrorResponse` 순으로 Decodable 시도
- `@preconcurrency import Alamofire`로 Sendable 경고 억제; 클로저 밖에서 `endpoint.path`를 `String`으로 추출 후 캡처

**페이지네이션 패턴 (SearchFoodViewModel, SetRemindNotiViewModel 등)**
- `currentPage: Int`, `totalPage: Int`, `isLastPage: Bool { currentPage == totalPage }`
- `searchXxx()`: `currentPage = 0` 리셋 후 page 0 호출, 성공 시 `currentPage` 유지
- `fetchXxx()`: `page: currentPage + 1` 호출 후 `currentPage += 1`

## 에이전트 및 커맨드 사용 규칙

요청 유형에 따라 아래 도구를 **자동으로** 사용한다. 사용자가 명시적으로 호출하지 않아도 된다.

| 요청 유형 | 사용할 도구 | 방법 |
|---|---|---|
| 새 기능 설계 | `architect` agent | Task tool로 소환 |
| 새 기능 구현 | `implementer` agent | Task tool로 소환 |
| ViewModel 테스트 작성 | `tester` agent | Task tool로 소환 |
| 커밋 요청 | `commit` 커맨드 | Skill tool로 실행 |
| 코드 리뷰 요청 | `review` 커맨드 | Skill tool로 실행 |
| 테스트 실행 요청 | `test` 커맨드 | Skill tool로 실행 |
| 새 기능 전체 구현 | `new-feature` 커맨드 | Skill tool로 실행 |

설계 → 구현 → 테스트 순서가 필요한 작업은 각 agent를 순서대로 호출한다.

## 테스트 구조

`BalanceEatTests/`
- `ViewModelTests/`: ViewModel 단위 테스트 (`@MainActor` 클래스)
- `Mocks/`: `MockXxxUseCase` — `searchFoodResult`, `callCount`, `capturedXxx` 프로퍼티로 검증
- `Fixtures/`: `XxxData+Fixture` — `static func fixture(...)` 팩토리 메서드로 테스트 데이터 생성
