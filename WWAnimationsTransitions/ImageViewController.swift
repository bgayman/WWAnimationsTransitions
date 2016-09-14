//
//  ImageViewController.swift
//  WWAnimationsTransitions
//
//  Created by Brad G. on 6/21/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    var image:UIImage?
    var transitionBegan = false
    
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.transitionBegan = false
        if let assetTransitionController = self.navigationController?.delegate as? AssetTransitionController{
            assetTransitionController.panGestureRecognizer = nil
            assetTransitionController.initiallyInteractive = false
            self.panGesture.addTarget(self, action: #selector(self.handlePan(_:)))
            self.imageView.addGestureRecognizer(panGesture)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageViewTopConstraint.constant = -(self.navigationController?.navigationBar.frame.maxY)!
    }

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed && !self.transitionBegan {
            if let assetTransitionController = self.navigationController?.delegate as? AssetTransitionController{
                assetTransitionController.panGestureRecognizer = sender
                assetTransitionController.initiallyInteractive = true
            }
            self.navigationController?.popViewController(animated: true)
            self.transitionBegan = true
        }
    }
}
