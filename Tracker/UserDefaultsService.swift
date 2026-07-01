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
        static let selectedFilter = "selectedFilter"
    }
    
    var isOnboardingAlreadySeen: Bool {
        get { defaults.bool(forKey: Key.onboardingAlreadySeen) }
        set { defaults.set(newValue, forKey: Key.onboardingAlreadySeen) }
    }
    
    var selectedFilter: TrackerFilter {
        get {
            guard
                let value = defaults.string(forKey: Key.selectedFilter),
                let filter = TrackerFilter(rawValue: value)
            else {
                return .all
            }
            
            return filter
        }
        
        set {
            defaults.set(newValue.rawValue, forKey: Key.selectedFilter)
        }
    }
}
