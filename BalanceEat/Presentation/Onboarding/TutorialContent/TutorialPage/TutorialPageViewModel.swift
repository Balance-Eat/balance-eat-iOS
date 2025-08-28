//
//  TutorialPageViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 8/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TutorialPageViewModel {
    static let shared = TutorialPageViewModel()
    
    let dataRelay = BehaviorRelay<TutorialData>(value: TutorialData())
    let goalTypeRelay = BehaviorRelay<GoalType>(value: .none)
    
    var BMRObservable: Observable<Int> {
        dataRelay
            .map { data -> Int in
                let weight = Double(data.weight ?? 0)
                let height = Double(data.height ?? 0)
                let age = Double(data.age ?? 0)
                
                switch data.gender {
                case .male:
                    let result = 10 * weight + 6.25 * height - 5 * age + 5
                    return Int(result)
                case .female:
                    let result = 10 * weight + 6.25 * height - 5 * age - 161
                    return Int(result)
                case .none:
                    return 0
                }
            }
    }
    let targetCaloriesRelay = BehaviorRelay<Int>(value: 0)
    let userCarbonRelay = BehaviorRelay<Float>(value: 0)
    let userProteinRelay = BehaviorRelay<Float>(value: 0)
    let userFatRelay = BehaviorRelay<Float>(value: 0)
    
    var targetCaloriesObservable: Observable<Int> {
        Observable.combineLatest(BMRObservable, goalTypeRelay, dataRelay) { bmr, goal, data -> Int in
            guard let activityCoef = data.activityLevel?.coefficient else { return 0 }
            var goalDiff = 0
            
            if data.activityLevel != ActivityLevel.none {
                switch goal {
                case .diet:
                    goalDiff = -500
                case .bulkUp:
                    goalDiff = 300
                case .maintain:
                    goalDiff = 0
                case .none:
                    break
                }
            }
            return Int(Double(bmr) * goal.coefficient * activityCoef) + goalDiff
        }
    }
    
    /// 목표에 따른 탄단지 비율
    /// - 1. 다이어트 : 탄 (35%), 단(40%), 지(25%)
    /// - 2. 벌크업 : 탄 (50%), 단(30%), 지(20%)
    /// - 3. 유지 : 탄(45%), 단(30%), 지(25%)
    var userCarbonObservable: Observable<Int> {
        Observable.combineLatest(targetCaloriesRelay, goalTypeRelay) { calory, goal -> Int in
            return Int(Double(calory) * goal.recommendedCarbonRatio)
        }
    }
    var userProteinObservable: Observable<Int> {
        Observable.combineLatest(targetCaloriesRelay, goalTypeRelay) { calory, goal -> Int in
            return Int(Double(calory) * goal.recommendedProteinRatio)
        }
    }
    var userFatObservable: Observable<Int> {
        Observable.combineLatest(targetCaloriesRelay, goalTypeRelay) { calory, goal -> Int in
            return Int(Double(calory) * goal.recommendedFatRatio)
        }
    }
    
    let disposeBag = DisposeBag()
    
    private init() {
        targetCaloriesObservable
            .bind(to: targetCaloriesRelay)
            .disposed(by: disposeBag)
        
        userCarbonObservable
            .map { Float($0) }
            .bind(to: userCarbonRelay)
            .disposed(by: disposeBag)
        
        userProteinObservable
            .map { Float($0) }
            .bind(to: userProteinRelay)
            .disposed(by: disposeBag)
        
        userFatObservable
            .map { Float($0) }
            .bind(to: userFatRelay)
            .disposed(by: disposeBag)
    }
    
    
}

extension TutorialPageViewModel {
    
    func generateRandomNickname() -> String {
        let adjectives = [
            "근육맛", "단백질왕", "칼로리짱", "헬린이", "샐러드마스터", "프로틴몬", "식단요정",
            "근육폭발", "스쿼트신", "덤벨귀요미", "푸드파이터", "헬스중독", "다이어터", "탄수제거왕",
            "닭가슴살러", "아보카도매니아", "단백질요정", "건강천사", "칼로리킬러", "헬린천재",
            "스무디러버", "브로콜리요정", "식단마스터", "프로틴캣", "근육프린세스", "덤벨고양이",
            "푸드퀸", "헬린공주", "칼로리버스터", "체중조절왕", "단백질쥬스", "헬스바니", "샐러드러버",
            "근육토끼", "프로틴팬더", "식단몬스터", "스쿼트킹", "덤벨팬", "헬린마스터", "칼로리천사",
            "단백질버니", "샐러드프린스", "근육냥이", "푸드토끼", "프로틴햄스터", "헬스판다",
            "체중관리러", "다이어트몬", "건강버스터", "탄수컷", "칼로리버니"
        ]
        
        let nouns = [
            "토끼", "고양이", "판다", "곰돌이", "햄스터", "치킨러버", "닭가슴살러",
            "아보카도", "프로틴볼", "스무디", "샐러드", "근육", "덤벨", "스쿼트",
            "푸드", "바디", "피트", "헬스", "프로틴", "요정"
        ]
        
        let randomAdjective = adjectives.randomElement() ?? "근육맛"
        let randomNoun = nouns.randomElement() ?? "토끼"
        
        return "\(randomAdjective)\(randomNoun)"
    }
    
}
