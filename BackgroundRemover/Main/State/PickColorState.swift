//
//  PickColorState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//

import UIKit

final class PickColorState: MainState {
    
    let selectedColor: UIColor
    
    init(selectedColor: UIColor, viewController: MainViewControllerProtocol) {
        self.selectedColor = selectedColor
        super.init(viewController: viewController)
    }
    
    override func enter() {
        super.enter()
        viewController.selectedColor = selectedColor
        viewController.changeColorPickerButton(selectedColor)
    }
}
