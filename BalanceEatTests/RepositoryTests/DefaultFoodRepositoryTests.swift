//
//  DefaultFoodRepositoryTests.swift
//  BalanceEatTests
//

import XCTest
@testable import BalanceEat

private extension BaseResponse {
    static func make(data: T) -> BaseResponse<T> {
        BaseResponse(status: "OK", message: "success", data: data, serverDatetime: "2026-03-24T00:00:00")
    }
}

@MainActor
final class DefaultFoodRepositoryTests: XCTestCase {

    private var mockAPIClient: MockAPIClient!
    private var sut: DefaultFoodRepository!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        sut = DefaultFoodRepository(apiClient: mockAPIClient)
    }

    override func tearDown() {
        mockAPIClient = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - searchFood

    func test_searchFood_성공시_FoodSearchResult_반환() async {
        let expectedFood = FoodData.fixture()
        let foodDTOForSearch = FoodDTOForSearch(
            id: expectedFood.id,
            uuid: expectedFood.uuid,
            name: expectedFood.name,
            userId: 1,
            servingSize: expectedFood.servingSize,
            unit: expectedFood.unit,
            perServingCalories: expectedFood.perServingCalories,
            carbohydrates: expectedFood.carbohydrates,
            protein: expectedFood.protein,
            fat: expectedFood.fat,
            brand: expectedFood.brand,
            isAdminApproved: true,
            createdAt: expectedFood.createdAt,
            updatedAt: expectedFood.createdAt
        )
        let searchResponseDTO = SearchFoodResponseDTO(
            totalItems: 1,
            currentPage: 0,
            itemsPerPage: 20,
            items: [foodDTOForSearch],
            totalPages: 1
        )
        mockAPIClient.requestResult = Result<BaseResponse<SearchFoodResponseDTO>, NetworkError>.success(
            .make(data: searchResponseDTO)
        )

        let result = await sut.searchFood(foodName: "닭가슴살", page: 0, size: 20)

        switch result {
        case .success(let foodSearchResult):
            XCTAssertEqual(foodSearchResult.totalItems, 1)
            XCTAssertEqual(foodSearchResult.totalPages, 1)
            XCTAssertEqual(foodSearchResult.items.count, 1)
            XCTAssertEqual(foodSearchResult.items.first?.name, expectedFood.name)
        case .failure(let error):
            XCTFail("성공 케이스에서 실패: \(error)")
        }
    }

    func test_searchFood_실패시_NetworkError_전달() async {
        mockAPIClient.requestResult = Result<BaseResponse<SearchFoodResponseDTO>, NetworkError>.failure(.noConnection)

        let result = await sut.searchFood(foodName: "닭가슴살", page: 0, size: 20)

        switch result {
        case .success:
            XCTFail("실패 케이스에서 성공")
        case .failure(let error):
            if case .noConnection = error {
                // 기대한 에러
            } else {
                XCTFail("예상치 못한 에러: \(error)")
            }
        }
    }

    func test_searchFood_올바른_endpointPath_사용() async {
        mockAPIClient.requestResult = Result<BaseResponse<SearchFoodResponseDTO>, NetworkError>.failure(.notFound)

        _ = await sut.searchFood(foodName: "닭가슴살", page: 0, size: 20)

        XCTAssertEqual(mockAPIClient.capturedEndpointPath, "/v1/foods/search")
        XCTAssertEqual(mockAPIClient.requestCallCount, 1)
    }

    // MARK: - createFood

    func test_createFood_성공시_FoodData_반환() async {
        let expectedFood = FoodData.fixture()
        let foodDTO = FoodDTO(
            id: expectedFood.id,
            uuid: expectedFood.uuid,
            name: expectedFood.name,
            servingSize: expectedFood.servingSize,
            unit: expectedFood.unit,
            perServingCalories: expectedFood.perServingCalories,
            carbohydrates: expectedFood.carbohydrates,
            protein: expectedFood.protein,
            fat: expectedFood.fat,
            brand: expectedFood.brand,
            createdAt: expectedFood.createdAt
        )
        mockAPIClient.requestResult = Result<BaseResponse<FoodDTO>, NetworkError>.success(
            .make(data: foodDTO)
        )

        let request = FoodCreateRequest(
            uuid: expectedFood.uuid,
            name: expectedFood.name,
            servingSize: expectedFood.servingSize,
            unit: expectedFood.unit,
            carbohydrates: expectedFood.carbohydrates,
            protein: expectedFood.protein,
            fat: expectedFood.fat,
            brand: expectedFood.brand
        )

        let result = await sut.createFood(request: request)

        switch result {
        case .success(let foodData):
            XCTAssertEqual(foodData.name, expectedFood.name)
            XCTAssertEqual(foodData.protein, expectedFood.protein)
        case .failure(let error):
            XCTFail("성공 케이스에서 실패: \(error)")
        }
    }

    func test_createFood_실패시_NetworkError_전달() async {
        mockAPIClient.requestResult = Result<BaseResponse<FoodDTO>, NetworkError>.failure(.internalServerError)

        let request = FoodCreateRequest(
            uuid: "test-uuid",
            name: "테스트 음식",
            servingSize: 100,
            unit: "g",
            carbohydrates: 10,
            protein: 20,
            fat: 5,
            brand: "테스트 브랜드"
        )

        let result = await sut.createFood(request: request)

        switch result {
        case .success:
            XCTFail("실패 케이스에서 성공")
        case .failure(let error):
            if case .internalServerError = error {
                // 기대한 에러
            } else {
                XCTFail("예상치 못한 에러: \(error)")
            }
        }
    }

    func test_createFood_올바른_endpointPath_사용() async {
        mockAPIClient.requestResult = Result<BaseResponse<FoodDTO>, NetworkError>.failure(.notFound)

        let request = FoodCreateRequest(
            uuid: "test-uuid",
            name: "테스트 음식",
            servingSize: 100,
            unit: "g",
            carbohydrates: 10,
            protein: 20,
            fat: 5,
            brand: ""
        )

        _ = await sut.createFood(request: request)

        XCTAssertEqual(mockAPIClient.capturedEndpointPath, "/v1/foods")
        XCTAssertEqual(mockAPIClient.requestCallCount, 1)
    }
}
