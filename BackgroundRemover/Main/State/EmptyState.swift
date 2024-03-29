//
//  EmptyState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//

import UIKit

final class EmptyState: MainState {
    override func enter() {
        super.enter()
        viewController.takenImage = UIImage(systemName: "photo")
        viewController.updateNavigationTitle("Выберите фото")
    }
}
