//
//  TrackerButtonIcons.swift
//  Tracker
//
//  Created by Роман Пичугин on 29.05.2026.
//
enum TrackerButtonIcons: String {
    case add = "plus"
    case completed = "checkmark"
    
    static func icon(for isCompleted: Bool) -> TrackerButtonIcons {
        return isCompleted ? .completed : .add
    }
}

