//
//  TutorialPageViewController.swift
//  BalanceEat
//
//  Created by 김견 on 8/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import UUIDV7

class TutorialPageViewController: UIViewController {
    private let viewModel: TutorialPageViewModel
    
    let currentPageRelay = PublishRelay<(currentIndex: Int, totalPages: Int)>()
    let goToNextPageRelay = PublishRelay<CreateUserDTO>()
    
    private var pages: [UIViewController] = []
    private(set) var currentIndex: Int = 0
    private var previousIndex: Int = 0
    
    private let disposeBag = DisposeBag()
    
    init() {
        viewModel = TutorialPageViewModel.shared
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPage()
        displayCurrentPage(animated: true)
    }
    
    private func setUpPage() {
        let basicInfoViewController = BasicInfoViewController()
        
        basicInfoViewController.inputCompleted
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.goToNextPage()
            })
            .disposed(by: disposeBag)
        
        let targetInfoViewController = TargetInfoViewController()
        
        targetInfoViewController.inputCompleted
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.goToNextPage()
            })
            .disposed(by: disposeBag)
        
        let activityLevelViewController = ActivityLevelViewController()
        
        activityLevelViewController.inputCompleted
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
//                let data = self.viewModel.dataRelay.value
//                let createUserDTO = CreateUserDTO(
//                    uuid: UUID.uuidV7String(),
//                    name: viewModel.generateRandomNickname(),
//                    gender: data.gender,
//                    age: data.age ?? 0,
//                    height: data.height ?? 0,
//                    weight: data.weight ?? 0,
//                    email: "",
//                    activityLevel: data.activityLevel ?? .none,
//                    smi: data.smi ?? 0,
//                    fatPercentage: data.fatPercentage ?? 0,
//                    targetWeight: data.targetWeight ?? 0,
//                    targetCalorie: viewModel.targetCaloriesRelay.value,
//                    targetSmi: data.targetSmi ?? 0,
//                    targetFatPercentage: data.targetFatPercentage ?? 0,
//                    providerId: "",
//                    providerType: ""
//                    
//                )
//                self.goToNextPageRelay.accept(createUserDTO)
                self.goToNextPage()
            })
            .disposed(by: disposeBag)
        
        let macroSettingViewController = MacroSettingViewController()
        
        pages.append(basicInfoViewController)
        pages.append(targetInfoViewController)
        pages.append(activityLevelViewController)
        pages.append(macroSettingViewController)
    }
    
    private func displayCurrentPage(animated: Bool) {
        if let currentChild = children.first {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }
        
        let vc = pages[currentIndex]
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        currentPageRelay.accept((currentIndex: currentIndex, totalPages: pages.count))
        previousIndex = currentIndex
    }
    
    func goToNextPage() {
        guard currentIndex + 1 < pages.count else { return }
        previousIndex = currentIndex
        currentIndex += 1
        displayCurrentPage(animated: true)
    }
    
    func goToPreviousPage() {
        guard currentIndex - 1 >= 0 else { return }
        previousIndex = currentIndex
        currentIndex -= 1
        displayCurrentPage(animated: true)
    }
}
