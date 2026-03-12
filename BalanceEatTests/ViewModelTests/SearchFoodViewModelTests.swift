//
//  SearchFoodViewModelTests.swift
//  BalanceEatTests
//

@testable import BalanceEat
import XCTest
import RxSwift

@MainActor
final class SearchFoodViewModelTests: XCTestCase {

    private var sut: SearchFoodViewModel!
    private var mockFoodUseCase: MockFoodUseCase!
    private var disposeBag: DisposeBag!

    override func setUp() async throws {
        try await super.setUp()
        mockFoodUseCase = MockFoodUseCase()
        disposeBag = DisposeBag()
        sut = SearchFoodViewModel(foodUseCase: mockFoodUseCase)
    }

    override func tearDown() async throws {
        sut = nil
        mockFoodUseCase = nil
        disposeBag = nil
        try await super.tearDown()
    }

    // MARK: - searchFood: 결과 검증

    func test_searchFood_성공시_결과_업데이트() async {
        // Given
        let foods = [FoodData.fixture(id: 1, name: "닭가슴살"), FoodData.fixture(id: 2, name: "현미밥")]
        mockFoodUseCase.searchFoodResult = .success(.fixture(items: foods))

        // When
        await sut.searchFood(foodName: "닭")

        // Then
        XCTAssertEqual(sut.searchFoodResultRelay.value.count, 2)
    }

    func test_searchFood_성공시_totalPage_업데이트() async {
        // Given
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 5))

        // When
        await sut.searchFood(foodName: "쌀")

        // Then
        XCTAssertEqual(sut.totalPage, 5)
    }

    func test_searchFood_성공시_currentPage_0으로_리셋() async {
        // Given: searchFood → fetchSearchFood 순서로 currentPage를 1로 올림
        // (초기 totalPage=0이므로 isLastPage=true → fetchSearchFood 단독 호출 불가)
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 3))
        await sut.searchFood(foodName: "닭")        // currentPage=0, totalPage=3
        await sut.fetchSearchFood(foodName: "닭")   // currentPage=1
        XCTAssertEqual(sut.currentPage, 1)

        // When: searchFood 호출 시 currentPage 초기화
        await sut.searchFood(foodName: "닭가슴살")

        // Then
        XCTAssertEqual(sut.currentPage, 0)
    }

    func test_searchFood_실패시_에러메시지_저장() async {
        // Given
        let error = NetworkError.serverError(500)
        mockFoodUseCase.searchFoodResult = .failure(error)

        // When
        await sut.searchFood(foodName: "닭")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, error.description)
    }

    func test_searchFood_실패시_기존결과_변경없음() async {
        // Given: 먼저 성공 결과 설정
        let food = FoodData.fixture(name: "기존음식")
        mockFoodUseCase.searchFoodResult = .success(.fixture(items: [food]))
        await sut.searchFood(foodName: "기존")

        // When: 이후 실패
        mockFoodUseCase.searchFoodResult = .failure(.serverError(500))
        await sut.searchFood(foodName: "실패검색")

        // Then: 이전 결과가 유지되지 않음 (searchFood는 currentPage=0으로 초기화)
        // 실패 시 searchFoodResultRelay는 변경되지 않음 → 이전 값 유지
        XCTAssertEqual(sut.searchFoodResultRelay.value.count, 1)
    }

    func test_searchFood_UseCase_정확히_1회_호출() async {
        // When
        await sut.searchFood(foodName: "닭")

        // Then
        XCTAssertEqual(mockFoodUseCase.searchFoodCallCount, 1)
    }

    func test_searchFood_UseCase에_올바른_인자_전달() async {
        // When
        await sut.searchFood(foodName: "현미밥")

        // Then
        XCTAssertEqual(mockFoodUseCase.capturedSearchFoodName, "현미밥")
        XCTAssertEqual(mockFoodUseCase.capturedSearchPage, 0)
        XCTAssertEqual(mockFoodUseCase.capturedSearchSize, 20)
    }

    // MARK: - fetchSearchFood: 페이지네이션

    func test_fetchSearchFood_성공시_결과_누적() async {
        // Given: 첫 검색으로 결과 세팅
        let firstFoods = [FoodData.fixture(id: 1, name: "닭가슴살")]
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 3, items: firstFoods))
        await sut.searchFood(foodName: "닭")

        // When: 다음 페이지 로드
        let secondFoods = [FoodData.fixture(id: 2, name: "닭볶음")]
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 3, items: secondFoods))
        await sut.fetchSearchFood(foodName: "닭")

        // Then: 기존 결과 + 새 결과
        XCTAssertEqual(sut.searchFoodResultRelay.value.count, 2)
    }

    func test_fetchSearchFood_isLastPage시_UseCase_미호출() async {
        // Given: currentPage == totalPage (마지막 페이지)
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 1))
        await sut.searchFood(foodName: "닭")
        // searchFood 후 currentPage=0, totalPage=1 → isLastPage = false
        // fetchSearchFood 한 번 호출하면 currentPage=1 → isLastPage = true
        await sut.fetchSearchFood(foodName: "닭")
        let callCountBefore = mockFoodUseCase.searchFoodCallCount

        // When: isLastPage 상태에서 fetchSearchFood 재호출
        await sut.fetchSearchFood(foodName: "닭")

        // Then: 추가 호출 없음
        XCTAssertEqual(mockFoodUseCase.searchFoodCallCount, callCountBefore)
    }

    func test_fetchSearchFood_currentPage_증가() async {
        // Given
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 5))
        await sut.searchFood(foodName: "닭")
        XCTAssertEqual(sut.currentPage, 0)

        // When
        await sut.fetchSearchFood(foodName: "닭")

        // Then
        XCTAssertEqual(sut.currentPage, 1)
    }

    func test_fetchSearchFood_실패시_에러메시지_저장() async {
        // Given: totalPage > currentPage 상태 만들기
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 3))
        await sut.searchFood(foodName: "닭")

        // When
        let error = NetworkError.serverError(500)
        mockFoodUseCase.searchFoodResult = .failure(error)
        await sut.fetchSearchFood(foodName: "닭")

        // Then
        XCTAssertEqual(sut.toastMessageRelay.value, error.description)
    }

    func test_fetchSearchFood_로딩흐름_true후_false() async {
        // Given: 다음 페이지가 있는 상태
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 5))
        await sut.searchFood(foodName: "닭")

        var loadingStates: [Bool] = []
        sut.isLoadingNextPageRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        await sut.fetchSearchFood(foodName: "닭")

        // Then: [false(초기), true(로딩중), false(완료)]
        XCTAssertEqual(loadingStates, [false, true, false])
    }

    func test_fetchSearchFood_실패시_로딩_false로_복귀() async {
        // Given
        mockFoodUseCase.searchFoodResult = .success(.fixture(totalPages: 5))
        await sut.searchFood(foodName: "닭")

        var loadingStates: [Bool] = []
        sut.isLoadingNextPageRelay
            .subscribe(onNext: { loadingStates.append($0) })
            .disposed(by: disposeBag)

        // When
        mockFoodUseCase.searchFoodResult = .failure(.serverError(500))
        await sut.fetchSearchFood(foodName: "닭")

        // Then: 실패 후에도 로딩이 false로 복귀
        XCTAssertEqual(loadingStates.last, false)
    }
}
