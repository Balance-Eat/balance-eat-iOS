//
//  DietListViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 9/29/25.
//
import Foundation
import RxSwift
import RxCocoa

final class DietListViewModel: BaseViewModel {
    private let userUseCase: UserUseCaseProtocol
    private let dietUseCase: DietUseCaseProtocol
    
    let userDataRelay = BehaviorRelay<UserData?>(value: nil)
    let monthDataCache = BehaviorRelay<[String: [String: [DietData]] ]>(value: [:])
    let selectedDate = BehaviorRelay<Date>(value: Date())
    let selectedDayDataCache = BehaviorRelay<[DietData]>(value: [])
    let ateDateRelay = BehaviorRelay<Set<Date>>(value: [])

    init(userUseCase: UserUseCaseProtocol, dietUseCase: DietUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.dietUseCase = dietUseCase
        super.init()
        
        setBinding()
    }
    
    private func getUserId() -> String {
        switch userUseCase.getUserId() {
        case .success(let userId): return String(userId)
        case .failure(let failure):
            handleError(failure, prefix: "유저 아이디 불러오기 실패: ")
            return ""
        }
    }
    
    private func getUserUUID() -> String {
        switch userUseCase.getUserUUID() {
        case .success(let uuid): return String(uuid)
        case .failure(let failure):
            handleError(failure, prefix: "유저 UUID 불러오기 실패: ")
            return ""
        }
    }
    
    func getUser() async {
        loadingRelay.accept(true)
        let response = await userUseCase.getUser(uuid: getUserUUID())
        switch response {
        case .success(let userData): userDataRelay.accept(userData)
        case .failure(let failure): handleError(failure, prefix: "유저 데이터 불러오기 실패: ")
        }
        loadingRelay.accept(false)
    }
    
    func getMonthlyDiets(year: Int = 0, month: Int = 0) async {
        let calendar = Calendar.current
        let year = year == 0 ? calendar.component(.year, from: selectedDate.value) : year
        let month = month == 0 ? calendar.component(.month, from: selectedDate.value) : month
        let userId = getUserId()
        
        if monthDataCache.value.keys.contains("\(year)-\(month)") {
            return
        }
        
        loadingRelay.accept(true)
        let response = await dietUseCase.getMonthlyDiet(year: year, month: month, userId: userId)
        switch response {
        case .success(let dietDTOs):
            var currentCache = monthDataCache.value
            let yearMonthKey = "\(year)-\(month)"
            var dailyDict: [String: [DietData]] = [:]
            
            for diet in dietDTOs {
                dailyDict[diet.consumeDate, default: []].append(diet.toDietData())
                
                var current = ateDateRelay.value
                current.insert(convertToDate(diet.consumeDate) ?? Date())
                ateDateRelay.accept(current)
            }
            
            currentCache[yearMonthKey] = dailyDict
            monthDataCache.accept(currentCache)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let todayKey = formatter.string(from: selectedDate.value)
            selectedDayDataCache.accept(dailyDict[todayKey] ?? [])
            
        case .failure(let failure):
            handleError(failure, prefix: "식단 정보 불러오기 실패: ")
        }
        loadingRelay.accept(false)
    }
    
    private func setBinding() {
        selectedDate
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateKey = dateFormatter.string(from: date)
                
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "yyyy-M"
                let monthKey = monthFormatter.string(from: date)
                
                if let monthDict = self.monthDataCache.value[monthKey] {
                    self.selectedDayDataCache.accept(monthDict[dateKey] ?? [])
                } else {
                    Task {
                        await self.getMonthlyDiets()
                        let updatedMonthDict = self.monthDataCache.value[monthKey]
                        self.selectedDayDataCache.accept(updatedMonthDict?[dateKey] ?? [])
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    
    private func convertToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
}
