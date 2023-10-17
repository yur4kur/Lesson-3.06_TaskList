//
//  AppDelegate.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit
import CoreData

// MARK: - AppDelegate
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Public methods
    func applicationWillTerminate(_ application: UIApplication) {
        StorageManager.shared.saveContext()
    }
}

