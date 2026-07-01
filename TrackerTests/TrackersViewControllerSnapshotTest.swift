//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Роман Пичугин on 01.07.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    func testTrackersViewController() {
        let vc = TrackersViewController()

        vc.overrideUserInterfaceStyle = .light
        vc.loadViewIfNeeded()
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }
}
