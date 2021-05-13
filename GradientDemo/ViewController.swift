//
//  ViewController.swift
//  GradientDemo
//
//  Created by Trung Hoang on 13/05/2021.
//

import UIKit

enum PanDirections: Int {
    case Right
    case Left
    case Bottom
    case Top
    case TopLeftToBottomRight
    case TopRightToBottomLeft
    case BottomLeftToTopRight
    case BottomRightToTopLeft
}

class ViewController: UIViewController, CAAnimationDelegate {
    var colorSets = [[CGColor]]()
    var currentColorSet: Int = 0
    var gradientLayer: CAGradientLayer!
    var panDirection: PanDirections?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createColorSets()
        createGradientLayer()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(gesture)
        
        let twoFingerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerTapGesture(_:)))
        twoFingerTapGesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoFingerTapGesture)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = colorSets[currentColorSet]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        view.layer.addSublayer(gradientLayer)
    }
    
    func createColorSets() {
        colorSets.append([UIColor.red.cgColor, UIColor.yellow.cgColor])
        colorSets.append([UIColor.green.cgColor, UIColor.magenta.cgColor])
        colorSets.append([UIColor.gray.cgColor, UIColor.lightGray.cgColor])
    }
    
    @objc
    func handleTapGesture(_ sender: Any) {
        currentColorSet += 1
        if currentColorSet == colorSets.count {
            currentColorSet = 0
        }
        
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.delegate = self
        colorChangeAnimation.duration = 2.0
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = .forwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    
    @objc
    func handleTwoFingerTapGesture(_ sender: Any) {
        let secondColorLocation = arc4random_uniform(100)
        let firstColorLocation = arc4random_uniform(secondColorLocation - 1)
        gradientLayer.locations = [NSNumber(value: Double(firstColorLocation)/100.0), NSNumber(value: Double(secondColorLocation)/100.0)]
        
        print(gradientLayer.locations!)
    }
    
    @objc
    func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        let velocity = gestureRecognizer.velocity(in: self.view)
     
        if gestureRecognizer.state == .changed {
            if velocity.x > 300.0 {
                // In this case the direction is generally towards Right.
                // Below are specific cases regarding the vertical movement of the gesture.
     
                if velocity.y > 300.0 {
                    // Movement from Top-Left to Bottom-Right.
                    panDirection = PanDirections.TopLeftToBottomRight
                }
                else if velocity.y < -300.0 {
                    // Movement from Bottom-Left to Top-Right.
                    panDirection = PanDirections.BottomLeftToTopRight
                }
                else {
                    // Movement towards Right.
                    panDirection = PanDirections.Right
                }
            }
            else if velocity.x < -300.0 {
                // In this case the direction is generally towards Left.
                // Below are specific cases regarding the vertical movement of the gesture.
     
                if velocity.y > 300.0 {
                    // Movement from Top-Right to Bottom-Left.
                    panDirection = PanDirections.TopRightToBottomLeft
                }
                else if velocity.y < -300.0 {
                    // Movement from Bottom-Right to Top-Left.
                    panDirection = PanDirections.BottomRightToTopLeft
                }
                else {
                    // Movement towards Left.
                    panDirection = PanDirections.Left
                }
            }
            else {
                // In this case the movement is mostly vertical (towards bottom or top).
     
                if velocity.y > 300.0 {
                    // Movement towards Bottom.
                    panDirection = PanDirections.Bottom
                }
                else if velocity.y < -300.0 {
                    // Movement towards Top.
                    panDirection = PanDirections.Top
                }
                else {
                    // Do nothing.
                    panDirection = nil
                }
            }
        }
        else if gestureRecognizer.state == .ended {
            changeGradientDirection()
        }
    }
    
    func changeGradientDirection() {
        guard let panDirection = panDirection else { return }
        switch panDirection {
        case PanDirections.Right:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
        case PanDirections.Left:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
            
        case PanDirections.Bottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
        case PanDirections.Top:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            
        case PanDirections.TopLeftToBottomRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            
        case PanDirections.TopRightToBottomLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            
        case PanDirections.BottomLeftToTopRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
            
        default:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colorSets[currentColorSet]
        }
    }
}

