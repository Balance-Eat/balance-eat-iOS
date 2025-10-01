//
//  BaseViewController.swift
//  BalanceEat
//
//  Created by 김견 on 10/1/25.
//

import UIKit
import RxSwift
import RxCocoa
import Toast
import SnapKit

class BaseViewController<VM: BaseViewModel>: UIViewController {
    let viewModel: VM
    let disposeBag = DisposeBag()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let topContentView = UIView()
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        return stackView
    }()
    
    let loadingView = LoadingView()
    
    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBindings()
    }
    
    private func setupViews() {
        view.backgroundColor = .homeScreenBackground
        
        view.addSubview(topContentView)
        view.addSubview(scrollView)
        view.addSubview(loadingView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(mainStackView)
        
        topContentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(topContentView.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.loadingRelay
            .bind(to: loadingView.isLoading)
            .disposed(by: disposeBag)
        
        viewModel.errorMessageRelay
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message, duration: 1.5, position: .center)
            })
            .disposed(by: disposeBag)
    }
}
