//
//  MainState.swift
//  BackgroundRemover
//
//  Created by Sergei on 1.3.24..
//
import UIKit

public class MainState {
    weak var viewController: MainViewControllerProtocol!
    
    init(viewController: MainViewControllerProtocol) {
        self.viewController = viewController
    }
    
    static func state(_ state: Kind, viewController: MainViewControllerProtocol) -> MainState {
        
        switch state {
        case .openPhotoPicker:
            return OpenPhotoPickerState(viewController: viewController)
        case .changePhoto(let image):
            return ChangePhotoState(takenPhoto: image, viewController: viewController)
        case .empty:
            return EmptyState(viewController: viewController)
        case .openColorPicker:
            return OpenColorPickerState(viewController: viewController)
        case .pickColor(let color):
            return PickColorState(selectedColor: color, viewController: viewController)
        case .setupBackgroundColor:
            return SetupBackgoundState(viewController: viewController)
        case .acceptChanges:
            return AcceptChangesState(viewController: viewController, delegate: viewController.acceptDelegate)
        }
    }
    
    func enter() {
        viewController.updateNavigationTitle("")
    }
}

extension MainState {
    enum Kind {
        case openPhotoPicker
        case changePhoto(UIImage)
        case empty
        case openColorPicker
        case pickColor(UIColor)
        case setupBackgroundColor
        case acceptChanges
    }
}
