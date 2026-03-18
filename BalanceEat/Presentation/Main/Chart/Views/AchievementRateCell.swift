//
//  AchievementRateCell.swift
//  BalanceEat
//

import UIKit
import SnapKit

final class AchievementRateCell: UITableViewCell {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        return label
    }()
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        return label
    }()
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.trackTintColor = .systemGray5
        return progressView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        self.backgroundColor = .clear
        selectionStyle = .none

        let labelStack = UIStackView(arrangedSubviews: [dateLabel, percentLabel])
        labelStack.axis = .horizontal
        labelStack.distribution = .fillEqually

        let contentStack = UIStackView(arrangedSubviews: [labelStack, progressView])
        contentStack.axis = .vertical
        contentStack.spacing = 6

        contentView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        progressView.snp.makeConstraints { make in
            make.height.equalTo(8)
        }
    }

    func configure(stat: AchievementRateStat) {
        dateLabel.text = stat.date
        percentLabel.text = "\(Int(stat.percent))%"

        let progress = Float(stat.percent / 100)
        progressView.setProgress(progress, animated: false)

        if stat.percent > 100 {
            progressView.progressTintColor = .systemRed
        } else {
            progressView.progressTintColor = .systemGreen
        }
    }
}
