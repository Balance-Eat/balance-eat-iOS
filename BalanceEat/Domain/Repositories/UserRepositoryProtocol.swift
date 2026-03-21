//
//  UserRepository.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation

protocol UserRepository {
    func createUser(request: UserCreateRequest) async -> Result<Void, NetworkError>
    func updateUser(userData: UserData) async -> Result<Void, NetworkError>
    func getUser(uuid: String) async -> Result<UserData, NetworkError>
    func getUserUUID() -> Result<String, CoreDataError>
    func saveUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func deleteUserUUID(_ uuid: String) -> Result<Void, CoreDataError>
    func getUserId() -> Result<Int64, CoreDataError>
    func saveUserId(_ userId: Int64) -> Result<Void, CoreDataError>
    func deleteUserId(_ userId: Int64) -> Result<Void, CoreDataError>
}
