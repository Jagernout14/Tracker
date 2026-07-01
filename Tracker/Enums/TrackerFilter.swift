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
            return NSLocalizedString("All Trackers", comment: "")
        case .today:
            return NSLocalizedString("Trackers for Today", comment: "")
        case .completed:
            return NSLocalizedString("Completed", comment: "")
        case .notCompleted:
            return NSLocalizedString("Uncompleted", comment: "")
        }
    }
}
