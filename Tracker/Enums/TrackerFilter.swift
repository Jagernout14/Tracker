//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.07.2026.
//

import Foundation
enum TrackerFilter: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("allTrackers", comment: "")
        case .today:
            return NSLocalizedString("trackersForToday", comment: "")
        case .completed:
            return NSLocalizedString("completed", comment: "")
        case .notCompleted:
            return NSLocalizedString("uncompleted", comment: "")
        }
    }
}
