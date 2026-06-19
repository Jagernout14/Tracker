//
//  UserDefaultService.swift
//  Tracker
//
//  Created by Роман Пичугин on 19.06.2026.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private enum Key {
        static let onboardingAlreadySeen = "onboardingAlreadySeen"
    }
    
    var isOnboardingAlreadySeen: Bool {
        get { defaults.bool(forKey: Key.onboardingAlreadySeen) }
        set { defaults.set(newValue, forKey: Key.onboardingAlreadySeen) }
    }
}
