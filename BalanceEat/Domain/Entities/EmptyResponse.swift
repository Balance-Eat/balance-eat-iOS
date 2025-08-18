//
//  EmptyResponse.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//
import Foundation

struct EmptyData: Decodable {} 

struct EmptyResponse: Decodable {
    let data: EmptyData
    let message: String
    let serverDatetime: String
}
