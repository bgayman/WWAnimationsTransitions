//
//  AssetTransitionController.swift
//  WWAnimationsTransitions
//
//  Created by Brad G. on 6/21/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation
import UIKit


class AssetTransitionController: NSObject {
    var operation:UINavigationControllerOperation?
    var transitionDriver:AssetTransitionDriver?
    var panGestureRecognizer:UIPanGestureRecognizer?
    var initiallyInteractive = false
    var finished = false
    var animationItems = [AnimationItem]()
}

extension AssetTransitionController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        
        return self
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self
    }
}

extension AssetTransitionController: UIViewControllerInteractiveTransitioning{
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if let panGesture = self.panGestureRecognizer {
            self.transitionDriver = AssetTransitionDriver(operation:self.operation!, context:transitionContext, panGestureRecognizer:panGesture, items: self.animationItems)
        }
        else
        {
            self.transitionDriver = AssetTransitionDriver(operation:self.operation!, context:transitionContext, panGestureRecognizer:nil, items: self.animationItems)
        }
        self.transitionDriver?.items = self.animationItems
    }
    
    var wantsInteractiveStart: Bool{
        return initiallyInteractive
    }
}

extension AssetTransitionController: UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AssetTransitionDriver.animationDuration()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        if transitionCompleted {
            //Do some stuff
        }
    }
    
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return (transitionDriver?.transitionAnimator)!
    }
    
}
