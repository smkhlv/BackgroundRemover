//
//  OpenColorPickerState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//

final class OpenColorPickerState: MainState {
    override func enter() {
        super.enter()
        viewController.presentColorPicker()
    }
}
