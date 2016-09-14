//
//  AssetTransitionDriver.swift
//  WWAnimationsTransitions
//
//  Created by Brad G. on 6/21/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit

class AssetTransitionDriver{
    var transitionAnimator:UIViewPropertyAnimator?
    var operation:UINavigationControllerOperation?
    var context:UIViewControllerContextTransitioning
    var panGestureRecognizer:UIPanGestureRecognizer?
    var itemFrameAnimator:UIViewPropertyAnimator?
    var items:[AnimationItem]?
    
    init(operation:UINavigationControllerOperation, context:UIViewControllerContextTransitioning, panGestureRecognizer:UIPanGestureRecognizer?, items:[AnimationItem]) {
        self.operation = operation
        self.context = context
        self.panGestureRecognizer = panGestureRecognizer
        self.panGestureRecognizer?.addTarget(self, action: #selector(self.updateInteraction(_:)))
        self.items = items
    
        let fromVC = self.context.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = self.context.viewController(forKey: UITransitionContextViewControllerKey.to)
        toVC?.view.alpha = 0.0
        self.context.containerView.addSubview((toVC?.view)!)
        self.setupTransitionAnimator({
            fromVC?.view.alpha = 0.0
            if toVC is ViewController{
                toVC?.view.alpha = 1.0
            }
            
            }, transitionCompletion: { position in
                if position == .end{
                    fromVC?.view.removeFromSuperview()
                    toVC?.view.alpha = 1.0
                }
                else
                {
                    self.context.containerView.subviews.forEach{
                        if $0 !== fromVC?.view{
//                            $0.removeFromSuperview()
                        }
                    }
                }
                
        })
        
        self.context.containerView.backgroundColor = UIColor.white
        self.items?.forEach{
            self.context.containerView.addSubview($0.imageView!)
            if let pan = self.panGestureRecognizer {
                self.items?.first?.imageView?.addGestureRecognizer(pan)
            }
            $0.imageView?.frame = $0.initialFrame
        }
        if !self.context.isInteractive
        {
            self.animate(.end)
            self.transitionAnimator?.startAnimation()
        }
    }
    
    static func animationDuration() -> TimeInterval {
        return AssetTransitionDriver.propertyAnimator().duration
    }
    
    static func propertyAnimator(_ initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator{
        let timingParameters = UISpringTimingParameters(mass: 2.5, stiffness: 1400, damping: 95, initialVelocity: initialVelocity)
        return UIViewPropertyAnimator(duration: 5.0, timingParameters: timingParameters)
    }
    
    func timingCurveVelocity() -> CGVector
    {
        if let point = self.panGestureRecognizer?.velocity(in: self.context.containerView){
            return CGVector(dx: point.x, dy: point.y)
        }
        return CGVector.zero
    }
    
    func setupTransitionAnimator(_ transitionAnimations:@escaping ()->(), transitionCompletion:@escaping (UIViewAnimatingPosition)->()){
        let transitionDuration = AssetTransitionDriver.animationDuration()
        
        self.transitionAnimator = UIViewPropertyAnimator(duration: transitionDuration, curve: .easeOut, animations: transitionAnimations)
        
        self.transitionAnimator?.addAnimations(transitionAnimations)
        
        transitionAnimator?.addCompletion{ [unowned self] (position) in
            
            transitionCompletion(position)
            
            let completed = (position == .end)
            
            self.context.completeTransition(completed)
        }
    }
    
    @objc func updateInteraction(_ fromGesture:UIPanGestureRecognizer){
        switch fromGesture.state {
        case .began,.changed:
            
            // Ask the gesture recognizer for it's translation
            let translation = fromGesture.translation(in: self.context.containerView)
            
            // Calculate the percent complete
            let percentComplete = (self.transitionAnimator?.fractionComplete)! + progressStepFor(translation)
            
            // Update the transition animator's fractionComplete to scrub it's animations
            self.transitionAnimator?.fractionComplete = percentComplete
            
            // Inform the transition context of the updated percent complete
            self.context.updateInteractiveTransition(percentComplete)
            
            // Update each transiton item for the
            self.updateItemsForInteractive(translation)
            
            // Reset the gestures translation
            fromGesture.setTranslation(CGPoint.zero, in: self.context.containerView)
            
        case .ended, .cancelled:
            
            // End the interactive phase of the transition
            self.endInteraction()
        default:
            break
        }
    }
    
    func progressStepFor(_ translation:CGPoint) -> CGFloat {
        let item = self.items?.first
        let centerXDistance = (item?.imageView?.center.x)! - self.context.containerView.center.x
        let centerYDistance = (item?.imageView?.center.y)! - self.context.containerView.center.y
        let percent = sqrt(centerXDistance * centerXDistance + centerYDistance * centerYDistance) / 500.0
        return percent
    }
    
    func updateItemsForInteractive(_ translation:CGPoint)
    {
        let progress = self.progressStepFor(translation)
        
        for item in self.items!{
            let shinkX = (item.targetFrame.width - item.initialFrame.width) * progress
            let shinkY  = (item.targetFrame.height - item.initialFrame.height) * progress
            item.imageView?.center = CGPoint(x: (item.imageView?.center.x)!  + translation.x,y: (item.imageView?.center.y)! + translation.y)
            item.imageView?.bounds.size = CGSize(width: shinkX + item.initialFrame.width, height: shinkY + item.initialFrame.height)
        }
        
    }
    
    func completionPosition() -> UIViewAnimatingPosition{
        let item = self.items?.first
        let centerXDistance = (item?.imageView?.center.x)! - self.context.containerView.center.x
        let centerYDistance = (item?.imageView?.center.y)! - self.context.containerView.center.y
        
        if sqrt(centerXDistance * centerXDistance + centerYDistance * centerYDistance) > 20.0 {
            return .end
        }
        return .start
    }
    
    func endInteraction(){
        guard self.context.isInteractive else { return }
        
        let completionPosition = self.completionPosition()
        if completionPosition == .end {
            self.context.finishInteractiveTransition()
        }else{
            self.context.cancelInteractiveTransition()
        }
        
        animate(completionPosition)
    }
    
    func animate(_ toPosition: UIViewAnimatingPosition){
        let itemFrameAnimator = AssetTransitionDriver.propertyAnimator(timingCurveVelocity())
        itemFrameAnimator.addAnimations{
            for item in self.items!{
                item.imageView?.frame = (toPosition == .end ? item.targetFrame : item.initialFrame)
            }
        }
        
        itemFrameAnimator.addCompletion {[unowned self] postion in
            if toPosition == .end
            {
                self.items?.forEach{
                    let targetFrame = $0.initialFrame
                    $0.initialFrame = $0.targetFrame
                    $0.targetFrame = targetFrame
//                    $0.imageView?.removeFromSuperview()
                }
            }
        }
        
        itemFrameAnimator.startAnimation()
        self.itemFrameAnimator = itemFrameAnimator
        
        transitionAnimator?.isReversed = (toPosition == .start)
        
        if transitionAnimator?.state == .inactive{
            transitionAnimator?.startAnimation()
        }else{
            let durationFactor = CGFloat(itemFrameAnimator.duration / (transitionAnimator?.duration)!)
            transitionAnimator?.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        }
    }
    
    func pauseAnimation(){
        itemFrameAnimator?.stopAnimation(true)
        
        transitionAnimator?.pauseAnimation()
        
        self.context.pauseInteractiveTransition()
    }
}




















