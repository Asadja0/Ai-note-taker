//
//  Theme.swift
//  NotesAudio
//
//  Created on 13/03/2025.
//

import UIKit

struct Theme {
    // Main colors
    static let primary = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark gray
    static let secondary = UIColor(red: 0.1, green: 0.6, blue: 0.8, alpha: 1.0) // Teal blue
    static let accent = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0) // Coral red
    
    // Background colors
    static let background = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0) // Almost white
    static let darkBackground = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) // Almost black
    
    // Card colors
    static let cardBackground = UIColor.white
    static let cardShadowColor = UIColor.black.withAlphaComponent(0.1)
    
    // Text colors
    static let textPrimary = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark gray
    static let textSecondary = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Medium gray
    
    // Gradient colors
    static let gradientStart = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0) // Light blue-gray
    static let gradientEnd = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0) // Slightly darker blue-gray
    
    // Fonts
    static let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let subtitleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let bodyFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let buttonFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    
    // Dimensions
    static let cornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 12
    static let cardElevation: CGFloat = 8
    static let standardPadding: CGFloat = 20
    
    // Animations
    static let standardAnimationDuration: TimeInterval = 0.3
    static let longAnimationDuration: TimeInterval = 0.5
    
    // Shadow
    static func applyShadow(to view: UIView, elevation: CGFloat = cardElevation) {
        view.layer.shadowColor = cardShadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: elevation/2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = elevation
        view.layer.masksToBounds = false
    }
    
    // Gradient background
    static func applyGradientBackground(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [gradientStart.cgColor, gradientEnd.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = cornerRadius
        
        // Ensure the gradient is at the back
        if let existingGradient = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            existingGradient.removeFromSuperlayer()
        }
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Button style
    static func styleButton(_ button: UIButton) {
        button.backgroundColor = secondary
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = buttonFont
        button.layer.cornerRadius = buttonCornerRadius
        applyShadow(to: button, elevation: 4)
    }
    
    // Card style
    static func styleCard(_ view: UIView) {
        view.backgroundColor = cardBackground
        view.layer.cornerRadius = cornerRadius
        applyShadow(to: view)
    }
}
