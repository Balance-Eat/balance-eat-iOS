//
//  LoadingView.swift
//  BalanceEat
//
//  Created by 김견 on 10/1/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoadingView: UIView {
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    private let blurEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.alpha = 0
        return view
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "잠시만 기다려 주세요"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let ringView = RotatingGradientRingView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindLoading()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(blurEffectView)
        addSubview(cardView)
        cardView.addSubview(ringView)
        cardView.addSubview(titleLabel)
        
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(160)
        }
        
        ringView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(92)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(ringView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(12)
        }
    }
    
    private func bindLoading() {
        isLoading
            .asDriver()
            .drive(onNext: { [weak self] show in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.25) {
                    self.blurEffectView.alpha = show ? 1 : 0
                    self.cardView.alpha = show ? 1 : 0
                }
            })
            .disposed(by: disposeBag)
    }
}

final class RotatingGradientRingView: UIView {

    private let shapeLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
        gradientLayer.mask = shapeLayer
        startAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        
        let lineWidth: CGFloat = 10
        let radius = (min(bounds.width, bounds.height) - lineWidth)/2
        let centerPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0.8
        
        gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    private func startAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 2.0
        rotation.repeatCount = .infinity
        layer.add(rotation, forKey: "rotationAnimation")
    }
}
