//
//  SceneDelegate.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

// MARK: - SceneDelegate
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Public properties
    var window: UIWindow?

    // MARK: - Public methods
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: TaskListViewController())
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        StorageManager.shared.saveContext()
    }
}

