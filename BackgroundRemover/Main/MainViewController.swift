//
//  MainViewController.swift
//  BackgroundRemover
//
//  Created by Sergei on 1.3.24..
//

import UIKit
import Photos

public protocol MainViewControllerProtocol: AnyObject {

    /// Returns selected color for backgroundImage
    var selectedColor: UIColor { get set }
    
    /// Image that person was taken
    var takenImage: UIImage? { get set }
    
    /// Delegate returns result of swapping backgound
    var acceptDelegate: AcceptDelegate! { get }
    
    /// Update navigation title in module
    /// - Parameters:
    ///   - title: set it for new changes
    func updateNavigationTitle(_ title: String)
    
    /// Call it for dissmissing controller inside module
    func dismissController()
    
    /// Call it for return to previews controller inside module
    func popViewController()
    
    /// Open ColorPicker module inside module
    func presentColorPicker()
    
    /// Open ImagePicker module inside module
    func presentImagePicker()
    
    /// Delegate method that calls when state changed to accepted
    /// - Parameters:
    ///   - image: result image with swapped backgound
    func changeColorPickerButton(_ color: UIColor)
}

public class MainViewController: UIViewController {
    
    private lazy var state = MainState.state(.empty, viewController: self)
    
    public var selectedColor: UIColor = .clear
    
    public var acceptDelegate: AcceptDelegate!
    
    public lazy var takenImage: UIImage? = self.takenPhoto.image {
        didSet {
            takenPhoto.image = takenImage
        }
    }
    
    convenience init(acceptDelegate: AcceptDelegate) {
        self.init()
        self.acceptDelegate = acceptDelegate
    }
    
    private lazy var takenPhoto: UIImageView = {
        let image = UIImage(systemName: "photo")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        return imageView
    }()
    
    private lazy var openPhotoPickerButton: UIButton? = {
        let button = UIButton(type: .system)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: takenPhoto.bottomAnchor, constant: 5),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 70),
            button.widthAnchor.constraint(equalToConstant: 70)
        ])
        return button
    }()
    
    private lazy var openColorPickerButton: UIButton? = {
        let button = UIButton(type: .system)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: takenPhoto.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            button.heightAnchor.constraint(equalToConstant: 70),
            button.widthAnchor.constraint(equalToConstant: 70)
        ])
        return button
    }()
    
    private func setupDefaultSettings() {
        view.backgroundColor = .black
        state = .state(.empty, viewController: self)
        state.enter()
    }
    
    private func setupButtons() {
        let openPhotoPickerImage = UIImage(systemName: "photo.badge.plus")
        openPhotoPickerButton?.setImage(openPhotoPickerImage, for: .normal)
        openPhotoPickerButton?.tintColor = .systemBlue
        openPhotoPickerButton?.addTarget(self, action: #selector(didTapOpenPhotoPicker), for: .touchUpInside)

        let openColorPickerImage = UIImage(systemName: "photo.fill.on.rectangle.fill")
        openColorPickerButton?.setImage(openColorPickerImage, for: .normal)
        openColorPickerButton?.tintColor = .systemBlue
        openColorPickerButton?.addTarget(self, action: #selector(didTapOpenColorPicker), for: .touchUpInside)
        
        let acceptChangesImage = UIImage(systemName: "checkmark")
        let acceptChangesButton = UIBarButtonItem(image: acceptChangesImage,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(didTapAcceptChanges)
        )
        navigationItem.rightBarButtonItem = acceptChangesButton
    }
    
    private func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    private var colorPicker: UIColorPickerViewController {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        return colorPicker
    }
    
    // MARK: - Actions
    
    @objc private func didTapOpenColorPicker() {
        state = .state(.openColorPicker, viewController: self)
        state.enter()
    }
    
    @objc private func didTapOpenPhotoPicker() {
        state = .state(.openPhotoPicker, viewController: self)
        state.enter()
    }
    
    @objc private func didTapAcceptChanges() {
        state = .state(.acceptChanges, viewController: self)
        state.enter()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultSettings()
        setupButtons()
    }
}

extension MainViewController: MainViewControllerProtocol {
    // MARK: - Public Methods
    
    public func updateNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    public func dismissController() {
        dismiss(animated: true)
    }
    
    public func presentColorPicker() {
        present(colorPicker, animated: true)
    }
    
    public func presentImagePicker() {
        let imagePicker = imagePicker(sourceType: .photoLibrary)
        present(imagePicker, animated: true)
    }
    
    public func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    public func changeColorPickerButton(_ color: UIColor) {
        openColorPickerButton?.tintColor = color
    }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, 
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        state = .state(.changePhoto(image), viewController: self)
        state.enter()
    }
}

extension MainViewController: UIColorPickerViewControllerDelegate {

    public func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        state = .state(.pickColor(viewController.selectedColor), viewController: self)
        state.enter()
        
        // process for changing color
        
        state = .state(.setupBackgroundColor, viewController: self)
        state.enter()
    }
}
