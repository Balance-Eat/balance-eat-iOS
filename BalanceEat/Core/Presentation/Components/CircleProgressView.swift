//
//  CircleProgressView.swift
//  BalanceEat
//
//  Created by 김견 on 7/13/25.
//

import UIKit

final class CircleProgressView: UIView {
    
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    private let progressLabel = UILabel()
    
    var maxValue: CGFloat = 2000
    var currentValue: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.width / 2 - 10
        
        let circlePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        
        trackLayer.path = circlePath.cgPath
        progressLayer.path = circlePath.cgPath
    }
    
    private func setupLayers() {
        
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        trackLayer.lineWidth = 16
        trackLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(trackLayer)
        
        progressLayer.strokeColor = UIColor.carlorieCircle.cgColor
        progressLayer.lineWidth = 16
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .square
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func setupLabel() {
        addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        progressLabel.textAlignment = .center
        progressLabel.font = UIFont.boldSystemFont(ofSize: 22)
        progressLabel.textColor = .black
        progressLabel.numberOfLines = 2
    }
    
    private func updateProgress() {
        let percentage = currentValue / maxValue
        progressLayer.strokeEnd = percentage
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let currentString = numberFormatter.string(from: NSNumber(value: Float(currentValue))) ?? "\(Int(currentValue))"
        let maxString = numberFormatter.string(from: NSNumber(value: Float(maxValue))) ?? "\(Int(maxValue))"
        
        let fullText = "\(currentString)\n/ \(maxString)"
        let attributedText = NSMutableAttributedString(string: fullText)
        
        attributedText.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 22),
            .foregroundColor: UIColor.black
        ], range: (fullText as NSString).range(of: currentString))
        
        attributedText.addAttributes([
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ], range: (fullText as NSString).range(of: "/ \(maxString)"))
        
        progressLabel.attributedText = attributedText
    }
}
