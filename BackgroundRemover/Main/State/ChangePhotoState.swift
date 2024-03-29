//
//  ChangePhotoState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//

import UIKit

final class ChangePhotoState: MainState {
    
    let takenPhoto: UIImage
    
    init(takenPhoto: UIImage, viewController: MainViewControllerProtocol) {
        self.takenPhoto = takenPhoto
        super.init(viewController: viewController)
    }
    
    override func enter() {
        super.enter()
        viewController.takenImage = takenPhoto
        viewController.dismissController()
    }
}
