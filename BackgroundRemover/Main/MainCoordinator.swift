//
//  MainCoordinator.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//

import UIKit

public protocol MainCoordinatorProtocol {
    
    /// Initializing and assembling Main module.
    static func createMainModule(acceptDelegate: AcceptDelegate) -> UIViewController
}

public final class MainCoordinator: MainCoordinatorProtocol {
    
    public static func createMainModule(acceptDelegate: AcceptDelegate) -> UIViewController {
         return MainViewController(acceptDelegate: acceptDelegate)
    }
}
