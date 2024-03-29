//
//  LauncherViewController.swift
//  BackgroundRemover
//
//  Created by Sergei on 2.3.24..
//
import UIKit

public class LauncherViewController: UIViewController {
    
    private lazy var launchMainButton: UIButton? = {
        let button = UIButton(type: .system)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLaunchMainButton()
        view.backgroundColor = .white
    }
    
    private func setupLaunchMainButton() {
        launchMainButton?.setTitle("Открыть главный экран", for: .normal)
        launchMainButton?.addTarget(self, action: #selector(openMain), for: .touchUpInside)
        launchMainButton?.setTitleColor(.white, for: .normal)
        launchMainButton?.backgroundColor = .systemPink
        launchMainButton?.layer.cornerRadius = 8
        if #available(iOS 15.0, *) {
            launchMainButton?.configuration = .filled()
        }
    }
    
    @objc func openMain() {
        let main = MainCoordinator.createMainModule(acceptDelegate: self) 
        navigationController?.pushViewController(main, animated: true)
    }
}

extension LauncherViewController: AcceptDelegate {
    public func changesWasAccepted(image: UIImage?) {
        debugPrint("Changes was Accepted!")
        debugPrint("You can use `AcceptDelegate`, for getting result image")
    }
}
