//
//  DietRepositoryProtocol.swift
//  BalanceEat
//
//  Created by 김견 on 8/22/25.
//

import Foundation

protocol DietRepositoryProtocol {
    func getDailyDiet(date: Date, userId: String) async -> Result<[DietDTO], NetworkError>
}
