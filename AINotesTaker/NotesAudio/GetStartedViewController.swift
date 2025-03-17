//
//  GetStartedViewController.swift
//  NotesAudio
//
//  Created on 12/03/2025.
//

import UIKit

class GetStartedViewController: UIViewController {
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Theme.secondary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a waveform image
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .light)
        imageView.image = UIImage(systemName: "waveform.circle", withConfiguration: config)
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "AI Notes Taker"
        label.textColor = Theme.primary
        label.font = Theme.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Transform your voice into text with AI-powered transcription and playback"
        label.textColor = Theme.textSecondary
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Let's Get Started", for: .normal)
        button.titleLabel?.font = Theme.buttonFont
        button.backgroundColor = Theme.secondary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Theme.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(getStartedButtonTapped), for: .touchUpInside)
        
        // Add shadow
        Theme.applyShadow(to: button, elevation: 6)
        
        return button
    }()
    
    private let featureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFeatures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateElements()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        
        // Add subviews
        view.addSubview(contentView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(featureStackView)
        contentView.addSubview(getStartedButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            featureStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            featureStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            featureStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            getStartedButton.topAnchor.constraint(equalTo: featureStackView.bottomAnchor, constant: 40),
            getStartedButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            getStartedButton.heightAnchor.constraint(equalToConstant: 56),
            getStartedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupFeatures() {
        // Create feature items
        let features = [
            ("mic.circle.fill", "Record your voice with a single tap"),
            ("text.bubble.fill", "Instant AI-powered transcription"),
            ("speaker.wave.2.fill", "Multiple voice playback options")
        ]
        
        // Add feature items to stack view
        for (icon, text) in features {
            let featureView = createFeatureView(icon: icon, text: text)
            featureStackView.addArrangedSubview(featureView)
        }
    }
    
    private func createFeatureView(icon: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = Theme.secondary
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = text
        textLabel.textColor = Theme.textPrimary
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textLabel.numberOfLines = 0
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func animateElements() {
        // Initial state - all elements slightly down and invisible
        let elements = [logoImageView, titleLabel, descriptionLabel, featureStackView, getStartedButton]
        elements.forEach { element in
            element.alpha = 0
            element.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        
        // Animate each element with a delay
        for (index, element) in elements.enumerated() {
            UIView.animate(withDuration: 0.6, delay: Double(index) * 0.15, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                element.alpha = 1
                element.transform = .identity
            })
        }
    }
    
  @objc private func getStartedButtonTapped() {
       // Add button animation
       AnimationUtility.pulse(view: getStartedButton) { [weak self] _ in
            let homeVC = HomeViewController()
            homeVC.modalPresentationStyle = .fullScreen
            homeVC.modalTransitionStyle = .crossDissolve
            self?.present(homeVC, animated: true)
        }
    }
}
