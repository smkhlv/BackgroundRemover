//
//  OpenPhotoPickerState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//

final class OpenPhotoPickerState: MainState {
    override func enter() {
        super.enter()
        viewController.presentImagePicker()
    }
}
