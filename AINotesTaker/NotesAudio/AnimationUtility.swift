//
//  AnimationUtility.swift
//  NotesAudio
//
//  Created on 13/03/2025.
//

import UIKit

class AnimationUtility {
    
    // Fade in animation
    static func fadeIn(view: UIView, duration: TimeInterval = Theme.standardAnimationDuration, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        view.alpha = 0
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            view.alpha = 1
        }, completion: completion)
    }
    
    // Fade out animation
    static func fadeOut(view: UIView, duration: TimeInterval = Theme.standardAnimationDuration, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            view.alpha = 0
        }, completion: completion)
    }
    
    // Scale animation
    static func pulse(view: UIView, duration: TimeInterval = 0.2, scale: CGFloat = 1.1, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration/2, animations: {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            UIView.animate(withDuration: duration/2, animations: {
                view.transform = CGAffineTransform.identity
            }, completion: completion)
        })
    }
    
    // Slide in from bottom
    static func slideInFromBottom(view: UIView, duration: TimeInterval = Theme.standardAnimationDuration, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        let originalPosition = view.frame
        view.frame = CGRect(x: view.frame.origin.x, 
                           y: UIScreen.main.bounds.height, 
                           width: view.frame.width, 
                           height: view.frame.height)
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            view.frame = originalPosition
        }, completion: completion)
    }
    
    // Slide out to bottom
    static func slideOutToBottom(view: UIView, duration: TimeInterval = Theme.standardAnimationDuration, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            view.frame = CGRect(x: view.frame.origin.x, 
                               y: UIScreen.main.bounds.height, 
                               width: view.frame.width, 
                               height: view.frame.height)
        }, completion: completion)
    }
    
    // Dropdown animation for voice options
    static func dropdown(view: UIView, duration: TimeInterval = Theme.standardAnimationDuration, completion: ((Bool) -> Void)? = nil) {
        view.transform = CGAffineTransform(rotationAngle: 0.01)
        view.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            view.transform = .identity
            view.alpha = 1
        }, completion: completion)
    }
    
    // Recording pulse animation
    static func startRecordingPulse(view: UIView) {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.8
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.infinity
        view.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    // Stop recording pulse animation
    static func stopRecordingPulse(view: UIView) {
        view.layer.removeAnimation(forKey: "pulse")
    }
}
