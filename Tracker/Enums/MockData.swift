//
//  MockData.swift
//  Tracker
//
//  Created by Роман Пичугин on 10.06.2026.
//

import UIKit

enum MockData {
    static let emojiSymbols = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    static let colors: [UIColor] = [
        assetColor("CardBiege"),
        assetColor("CardBiegeDust"),
        assetColor("CardBlue"),
        assetColor("CardBlueDust"),
        assetColor("CardBlueLight"),
        assetColor("CardGrape"),
        assetColor("CardGrapeDark"),
        assetColor("CardGrapeDust"),
        assetColor("CardGrapeLight"),
        assetColor("CardGreen"),
        assetColor("CardGreenBright"),
        assetColor("CardOrange"),
        assetColor("CardOrangeBrick"),
        assetColor("CardPink"),
        assetColor("CardPinkLight"),
        assetColor("CardPurple"),
        assetColor("CardRed"),
        assetColor("CardTransulent")
    ]
    
    private static func assetColor(_ name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            assertionFailure("Цвет в ассете по имени не нашелся")
            return .black
        }
        return color
    }
}
