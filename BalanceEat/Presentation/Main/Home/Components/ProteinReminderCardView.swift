//
//  ProteinReminderCardView.swift
//  BalanceEat
//
//  Created by 김견 on 7/13/25.
//

import UIKit
import SnapKit

final class ProteinReminderCardView: UIView {
    private let proteinTime: Date
    
    private let gradientBackgroundView = GradientView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🔔 다음 단백질 섭취 시간"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    init(proteinTime: Date) {
        self.proteinTime = proteinTime
        super.init(frame: .zero)
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        timeLabel.text = formatProteinIntakeTime(targetDate: proteinTime)
        
        self.addSubview(gradientBackgroundView)
        gradientBackgroundView.addSubview(titleLabel)
        gradientBackgroundView.addSubview(timeLabel)
        
        gradientBackgroundView.layer.cornerRadius = 16
        gradientBackgroundView.layer.masksToBounds = true 
        gradientBackgroundView.colors = [
            .proteinTimeCardStartBackground,
            .proteinTimeCardEndBackground
        ]
        
        gradientBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func formatProteinIntakeTime(targetDate: Date, currentDate: Date = Date()) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a h:mm"
        
        let formattedTime = dateFormatter.string(from: targetDate)
        
        let timeInterval = targetDate.timeIntervalSince(currentDate)
        
        if timeInterval <= 0 {
            return "\(formattedTime) (지났음)"
        }

        let totalMinutes = Int(timeInterval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        var timeRemainingText = ""
        if hours > 0 {
            timeRemainingText += "\(hours)시간 "
        }
        timeRemainingText += "\(minutes)분 후"
        
        return "\(formattedTime) (\(timeRemainingText))"
    }
}
