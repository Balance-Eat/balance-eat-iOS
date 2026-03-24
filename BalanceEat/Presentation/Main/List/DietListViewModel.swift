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
    
    private static let dailyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let monthlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-M"
        return formatter
    }()

    let userDataRelay = BehaviorRelay<UserData?>(value: nil)
    let monthDataCache = BehaviorRelay<[String: [String: [DietData]] ]>(value: [:])
    let selectedDate = BehaviorRelay<Date>(value: Date())
    let selectedDayDataCache = BehaviorRelay<[DietData]>(value: [])
    let ateDateRelay = BehaviorRelay<Set<Date>>(value: [])
    let dailyNutritionSummaryRelay: BehaviorRelay<(calorie: Double, carbohydrate: Double, protein: Double, fat: Double)> = .init(value: (0, 0, 0, 0))

    private var fetchDietTask: Task<Void, Never>?

    func clearMonthCache() {
        monthDataCache.accept([:])
    }

    init(userUseCase: UserUseCaseProtocol, dietUseCase: DietUseCaseProtocol) {
        self.userUseCase = userUseCase
        self.dietUseCase = dietUseCase
        super.init()
        
        setBinding()
    }
    
    private func getUserId() -> String? {
        switch userUseCase.getUserId() {
        case .success(let userId): return String(userId)
        case .failure(let failure):
            toastMessageRelay.accept("유저 아이디 불러오기 실패: \(failure.description)")
            return nil
        }
    }

    private func getUserUUID() -> String? {
        switch userUseCase.getUserUUID() {
        case .success(let uuid): return uuid
        case .failure(let failure):
            toastMessageRelay.accept("유저 UUID 불러오기 실패: \(failure.description)")
            return nil
        }
    }

    @MainActor
    func getUser() async {
        guard let uuid = getUserUUID() else { return }
        loadingRelay.accept(true)
        let response = await userUseCase.getUser(uuid: uuid)
        switch response {
        case .success(let userData): userDataRelay.accept(userData)
        case .failure(let failure): toastMessageRelay.accept("유저 데이터 불러오기 실패: \(failure.description)")
        }
        loadingRelay.accept(false)
    }

    @MainActor
    func getMonthlyDiets(year: Int = 0, month: Int = 0) async {
        guard let userId = getUserId() else { return }
        let calendar = Calendar.current
        let year = year == 0 ? calendar.component(.year, from: selectedDate.value) : year
        let month = month == 0 ? calendar.component(.month, from: selectedDate.value) : month

        loadingRelay.accept(true)
        let response = await dietUseCase.getMonthlyDiet(year: year, month: month, userId: userId)
        switch response {
        case .success(let dietDataList):
            var currentCache = monthDataCache.value
            let yearMonthKey = "\(year)-\(month)"
            var dailyDict: [String: [DietData]] = [:]

            var ateDates = ateDateRelay.value
            for diet in dietDataList {
                dailyDict[diet.consumeDate, default: []].append(diet)
                if let parsedDate = convertToDate(diet.consumeDate) {
                    ateDates.insert(parsedDate)
                }
            }
            ateDateRelay.accept(ateDates)

            currentCache[yearMonthKey] = dailyDict
            monthDataCache.accept(currentCache)

            let todayKey = DietListViewModel.dailyFormatter.string(from: selectedDate.value)
            selectedDayDataCache.accept(dailyDict[todayKey] ?? [])

        case .failure(let failure):
            toastMessageRelay.accept("식단 정보 불러오기 실패: \(failure.description)")
        }
        loadingRelay.accept(false)
    }
    
    private func setBinding() {
        selectedDate
            .subscribe(onNext: { [weak self] date in
                guard let self else { return }

                let dateKey = DietListViewModel.dailyFormatter.string(from: date)
                let monthKey = DietListViewModel.monthlyFormatter.string(from: date)

                if let monthDict = self.monthDataCache.value[monthKey] {
                    self.selectedDayDataCache.accept(monthDict[dateKey] ?? [])
                } else {
                    // 날짜가 빠르게 변경될 때 이전 fetch 요청을 취소하고 최신 날짜 데이터만 반영한다.
                    fetchDietTask?.cancel()
                    fetchDietTask = Task { @MainActor [weak self] in
                        guard let self else { return }
                        await getMonthlyDiets()
                        guard !Task.isCancelled else { return }
                        let updatedMonthDict = monthDataCache.value[monthKey]
                        selectedDayDataCache.accept(updatedMonthDict?[dateKey] ?? [])
                    }
                }
            })
            .disposed(by: disposeBag)

        selectedDayDataCache
            .subscribe(onNext: { [weak self] dietDatas in
                guard let self else { return }
                let totalCalories = dietDatas.flatMap { $0.items }.reduce(0.0) { $0 + $1.calories }
                let totalCarbon = dietDatas.flatMap { $0.items }.reduce(0.0) { $0 + $1.carbohydrates }
                let totalProtein = dietDatas.flatMap { $0.items }.reduce(0.0) { $0 + $1.protein }
                let totalFat = dietDatas.flatMap { $0.items }.reduce(0.0) { $0 + $1.fat }
                dailyNutritionSummaryRelay.accept((calorie: totalCalories, carbohydrate: totalCarbon, protein: totalProtein, fat: totalFat))
            })
            .disposed(by: disposeBag)
    }
    
    private static let hourMinuteInputFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    private static let hourMinuteOutputFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    static func formatConsumedTime(_ dateString: String) -> String? {
        guard let date = DietListViewModel.hourMinuteInputFormatter.date(from: dateString) else { return nil }
        return DietListViewModel.hourMinuteOutputFormatter.string(from: date)
    }

    private static let consumeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private func convertToDate(_ string: String) -> Date? {
        DietListViewModel.consumeDateFormatter.date(from: string)
    }
}
