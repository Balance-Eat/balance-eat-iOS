//
//  MockUserUseCase.swift
//  BalanceEatTests
//

@testable import BalanceEat
import Foundation

final class MockUserUseCase: UserUseCaseProtocol {
    var createUserResult: Result<Void, NetworkError> = .success(())
    var updateUserResult: Result<Void, NetworkError> = .success(())
    var getUserResult: Result<UserData, NetworkError> = .success(.fixture())
    var getUserUUIDResult: Result<String, CoreDataError> = .success("test-uuid")
    var saveUserUUIDResult: Result<Void, CoreDataError> = .success(())
    var deleteUserUUIDResult: Result<Void, CoreDataError> = .success(())
    var getUserIdResult: Result<Int64, CoreDataError> = .success(1)
    var saveUserIdResult: Result<Void, CoreDataError> = .success(())
    var deleteUserIdResult: Result<Void, CoreDataError> = .success(())

    func createUser(_ request: UserCreateRequest) async -> Result<Void, NetworkError> { createUserResult }
    func updateUser(_ userData: UserData) async -> Result<Void, NetworkError> { updateUserResult }
    func getUser(uuid: String) async -> Result<UserData, NetworkError> { getUserResult }
    func getUserUUID() -> Result<String, CoreDataError> { getUserUUIDResult }
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError> { saveUserUUIDResult }
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError> { deleteUserUUIDResult }
    func getUserId() -> Result<Int64, CoreDataError> { getUserIdResult }
    func saveUserId(_ userId: Int64) -> Result<Void, CoreDataError> { saveUserIdResult }
    func deleteUserId(_ userId: Int64) -> Result<Void, CoreDataError> { deleteUserIdResult }
}
