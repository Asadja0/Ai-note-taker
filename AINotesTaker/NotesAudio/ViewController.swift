//
//  ViewController.swift
//  NotesAudio
//
//  Created by Ali Javaid on 12/03/2025.
//

import UIKit

class ViewController: UIViewController {
    
    private let logoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Note Taker"
        label.textColor = Theme.primary
        label.font = Theme.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0 // Start invisible for animation
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your voice, intelligently transcribed"
        label.textColor = Theme.textSecondary
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0 // Start invisible for animation
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Theme.secondary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0 // Start invisible for animation
        
        // Create a microphone image
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        imageView.image = UIImage(systemName: "waveform.circle", withConfiguration: config)
        
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateElements()
        
        // Navigate to GetStartedViewController after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.navigateToGetStartedScreen()
        }
    }
    
    private func setupUI() {
        // Set up the background
        view.backgroundColor = Theme.background
        
        // Add subviews
        view.addSubview(logoContainer)
        logoContainer.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            logoContainer.widthAnchor.constraint(equalToConstant: 120),
            logoContainer.heightAnchor.constraint(equalToConstant: 120),
            
            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func animateElements() {
        // Animate logo first
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut, animations: { [weak self] in
            self?.logoImageView.alpha = 1
        }, completion: { _ in
            // Then animate title
            UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: { [weak self] in
                self?.titleLabel.alpha = 1
            }, completion: { _ in
                // Finally animate subtitle
                UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: { [weak self] in
                    self?.subtitleLabel.alpha = 1
                })
            })
        })
    }
    
    private func navigateToGetStartedScreen() {
        let getStartedVC = GetStartedViewController()
        getStartedVC.modalPresentationStyle = .fullScreen
        getStartedVC.modalTransitionStyle = .crossDissolve
        present(getStartedVC, animated: true)
    }
}
