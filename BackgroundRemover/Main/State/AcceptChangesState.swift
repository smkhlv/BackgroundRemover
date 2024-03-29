//
//  AcceptChangesState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//
import UIKit

public protocol AcceptDelegate: AnyObject {
    
    /// Delegate method that calls when state changed to accepted
    /// - Parameters:
    ///   - image: result image with swapped backgound
    func changesWasAccepted(image: UIImage?)
}

public final class AcceptChangesState: MainState {
    
    private weak var delegate: AcceptDelegate?
    
    init(viewController: MainViewControllerProtocol, delegate: AcceptDelegate) {
        self.delegate = delegate
        super.init(viewController: viewController)
    }
    
    override func enter() {
        super.enter()
        viewController.popViewController()
        delegate?.changesWasAccepted(image: viewController.takenImage)
    }
}
