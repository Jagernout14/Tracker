//
//  AppMetricaCore.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.07.2026.
//

import AppMetricaCore

final class AnalyticsService {

    static let shared = AnalyticsService()

    private init() {}

    func report(event: String, screen: String, item: String? = nil) {
        var params: [String: Any] = [
            "event": event,
            "screen": screen
        ]

        if let item {
            params["item"] = item
        }

        AppMetrica.reportEvent(name: "event", parameters: params)

        print("Analytics:", params)
    }
}
