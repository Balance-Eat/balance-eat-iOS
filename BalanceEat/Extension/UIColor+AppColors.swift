//
//  UIColor+AppColors.swift
//  BalanceEat
//

import UIKit

extension UIColor {
    // MARK: - Brand

    /// 주요 인터랙션 색상 (버튼, 선택 상태, 포커스 테두리)
    static let appPrimary: UIColor = .systemBlue

    // MARK: - State

    /// 위험/삭제 액션 색상
    static let appDestructive: UIColor = .systemRed

    /// 달성/성공/긍정 상태 색상
    static let appPositive: UIColor = .systemGreen

    /// 경고/주의 색상
    static let appWarning: UIColor = .systemOrange

    /// 낮은 우선순위/중립 강조 색상
    static let appCaution: UIColor = .systemYellow

    /// 변화 없음/기본 중립 색상
    static let appNeutral: UIColor = .systemGray

    // MARK: - Text

    /// 부제목 텍스트
    static let appSubtitleText: UIColor = .darkGray

    /// 보조 설명 텍스트
    static let appSecondaryText: UIColor = .gray

    // MARK: - Border / Divider

    /// 기본 테두리 / 비활성 구분선
    static let appBorder: UIColor = .lightGray

}
