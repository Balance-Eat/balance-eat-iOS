//
//  LoginViewController.swift
//  BalanceEat
//
//  Created by 김견 on 7/10/25.
//

import UIKit
import SnapKit
import RxSwift

class LoginViewController: UIViewController {
    private let appLogoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "BalanceEat_Logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        return stackView
    }()
    
    private let kakaoSignInButton: OAuthSignInButton = {
        let oAuthSignInButton = OAuthSignInButton(provider: .kakao)
        return oAuthSignInButton
    }()
    
    private let googleSignInButton: OAuthSignInButton = {
        let oAuthSignInButton = OAuthSignInButton(provider: .google)
        return oAuthSignInButton
    }()
    
    private let appleSignInButton: OAuthSignInButton = {
        let oAuthSignInButton = OAuthSignInButton(provider: .apple)
        return oAuthSignInButton
    }()
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setUpView()
//        setUpBinding()
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        view.addSubview(appLogoImageView)
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(kakaoSignInButton)
        stackView.addArrangedSubview(googleSignInButton)
        stackView.addArrangedSubview(appleSignInButton)
        
        appLogoImageView.snp.makeConstraints { make in
            make.width.equalTo(280)
            make.center.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
//    private func setUpBinding() {
//        kakaoSignInButton.tapObservable
//            .subscribe(onNext: { [weak self] in
//                print("카카오 로그인")
//                self?.navigateToMain()
//            })
//            .disposed(by: disposeBag)
//        
//        googleSignInButton.tapObservable
//            .subscribe(onNext: { [weak self] in
//                print("구글 로그인")
//                self?.navigateToMain()
//            })
//            .disposed(by: disposeBag)
//        
//        appleSignInButton.tapObservable
//            .subscribe(onNext: { [weak self] in
//                print("애플 로그인")
//                self?.navigateToMain()
//            })
//            .disposed(by: disposeBag)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
//    
//    private func navigateToMain() {
//        let mainViewController = MainViewController(uuid: <#String#>)
//        self.navigationController?.setViewControllers([mainViewController], animated: true)
//    }
}
