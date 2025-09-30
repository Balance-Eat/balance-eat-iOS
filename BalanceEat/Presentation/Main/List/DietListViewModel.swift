//
//  DietListViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/29/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DietListViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let dietUseCase: DietUseCaseProtocol
    
    let userDataRelay = BehaviorRelay<UserData?>(value: nil)
    
    let monthDataCache = BehaviorRelay<[String: [String: [DietData]] ]>(value: [:])
    let selectedDate = BehaviorRelay<Date>(value: Date())
    let selectedDayDataCache = BehaviorRelay<[DietData]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init(userUseCase: UserUseCaseProtocol, dietUseCase: DietUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.dietUseCase = dietUseCase
        
        setBinding()
    }
    
    private func getUserId() -> String {
        let userIdResponse = userUseCase.getUserId()
        
        switch userIdResponse {
        case .success(let userId):
            return String(userId)
        case .failure(let failure):
            print("faiture: \(failure)")
            return ""
        }
    }
    
    private func getUserUUID() -> String {
        let userIdResponse = userUseCase.getUserUUID()
        
        switch userIdResponse {
        case .success(let userId):
            return String(userId)
        case .failure(let failure):
            print("faiture: \(failure)")
            return ""
        }
    }
    
    func getUser() async {
        let getUserDataResponse = await userUseCase.getUser(uuid: getUserUUID())
        
        switch getUserDataResponse {
        case .success(let userData):
            userDataRelay.accept(userData)
        case .failure(let failure):
            print("유저 데이터 불러오기 실패: \(failure)")
        }
    }
    
    func getMonthlyDiets() async {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate.value)
        let month = calendar.component(.month, from: selectedDate.value)
        let userId = getUserId()
        
        let getMonthlyDietResponse = await dietUseCase.getMonthlyDiet(year: year, month: month, userId: userId)
        
        switch getMonthlyDietResponse {
        case .success(let dietDTOs):
            print("\(year)-\(month) 식단 정보: \(dietDTOs)")
            
            var currentCache = monthDataCache.value
            let yearMonthKey = "\(year)-\(month)"
            
            var dailyDict: [String: [DietData]] = [:]
            for diet in dietDTOs {
                let dateKey = diet.consumeDate
                dailyDict[dateKey, default: []].append(diet.toDietData())
            }
            
            currentCache[yearMonthKey] = dailyDict
            monthDataCache.accept(currentCache)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let todayKey = formatter.string(from: selectedDate.value)
            
            if let todayDietDatas = dailyDict[todayKey] {
                selectedDayDataCache.accept(todayDietDatas)
            } else {
                selectedDayDataCache.accept([])
            }
            
        case .failure(let failure):
            print("식단 정보 불러오기 실패: \(failure.localizedDescription)")
        }
    }

    private func setBinding() {
        selectedDate
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateKey = formatter.string(from: date)
                
                let yearMonthFormatter = DateFormatter()
                yearMonthFormatter.dateFormat = "yyyy-M"
                let yearMonthKey = yearMonthFormatter.string(from: date)
                
                if let monthDict = self.monthDataCache.value[yearMonthKey] {
                    self.selectedDayDataCache.accept(monthDict[dateKey] ?? [])
                } else {
                    Task {
                        await self.getMonthlyDiets()
                        let updatedMonthDict = self.monthDataCache.value[yearMonthKey]
                        self.selectedDayDataCache.accept(updatedMonthDict?[dateKey] ?? [])
                    }
                }
            })
            .disposed(by: disposeBag)
    }

}
