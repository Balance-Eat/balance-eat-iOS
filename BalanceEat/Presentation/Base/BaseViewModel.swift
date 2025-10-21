//
//  BaseViewModel.swift
//  BalanceEat
//
//  Created by 김견 on 10/1/25.
//


import Foundation
import RxSwift
import RxCocoa

class BaseViewModel {
    let loadingRelay = BehaviorRelay<Bool>(value: false)
    
    let toastMessageRelay = BehaviorRelay<String?>(value: nil)
    
    let disposeBag = DisposeBag()
    
    func handleError(_ error: Error, prefix: String = "") {
        toastMessageRelay.accept("\(prefix)\(error.localizedDescription)")
    }
}
