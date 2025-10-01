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
            updateProgress(animated: true)
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
        
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 16
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
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
    
    private func interpolateColor(from: UIColor, to: UIColor, fraction: CGFloat) -> UIColor {
        var fRed: CGFloat = 0, fGreen: CGFloat = 0, fBlue: CGFloat = 0, fAlpha: CGFloat = 0
        var tRed: CGFloat = 0, tGreen: CGFloat = 0, tBlue: CGFloat = 0, tAlpha: CGFloat = 0
        
        from.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        to.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)
        
        let red = fRed + (tRed - fRed) * fraction
        let green = fGreen + (tGreen - fGreen) * fraction
        let blue = fBlue + (tBlue - fBlue) * fraction
        let alpha = fAlpha + (tAlpha - fAlpha) * fraction
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func updateProgress(animated: Bool = true) {
        let percentage = max(0, min(currentValue / maxValue, 1))
        
        let newColor = interpolateColor(from: .systemBlue, to: .systemRed, fraction: percentage).cgColor
        
        if animated {
            let strokeAnim = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnim.fromValue = progressLayer.strokeEnd
            strokeAnim.toValue = percentage
            strokeAnim.duration = 0.5
            strokeAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = percentage
            progressLayer.add(strokeAnim, forKey: "strokeEnd")
            
            let colorAnim = CABasicAnimation(keyPath: "strokeColor")
            colorAnim.fromValue = progressLayer.strokeColor
            colorAnim.toValue = newColor
            colorAnim.duration = 0.5
            colorAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeColor = newColor
            progressLayer.add(colorAnim, forKey: "strokeColor")
            
        } else {
            progressLayer.strokeEnd = percentage
            progressLayer.strokeColor = newColor
        }
        
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
