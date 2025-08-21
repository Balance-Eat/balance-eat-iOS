//
//  BaseResponse.swift
//  BalanceEat
//
//  Created by 김견 on 8/21/25.
//
import Foundation

struct BaseResponse<T: Codable>: Codable {
    let status: String
    let message: String
    let data: T
    let serverDatetime: String
}
