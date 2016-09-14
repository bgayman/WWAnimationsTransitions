//
//  ViewController.swift
//  WWAnimationsTransitions
//
//  Created by Brad G. on 6/21/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let kSegueIdentifier = "ShowImage"
    let assetTransitionController = AssetTransitionController()
    var selectedImageView:UIImageView?
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Photos"
        self.navigationController?.delegate = self.assetTransitionController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.stackViewTopConstraint.constant = -(self.navigationController?.navigationBar.frame.maxY)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedImageView?.isHidden = false
    }

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView{
            let item = AnimationItem()
            item.imageView = UIImageView(frame: imageView.frame)
            item.imageView?.contentMode = imageView.contentMode
            item.imageView?.clipsToBounds = imageView.clipsToBounds
            item.imageView?.image = imageView.image
            item.initialFrame = (self.navigationController?.view.convert(imageView.bounds, from: imageView))!
            item.targetFrame = (self.navigationController?.view.convert(self.view.bounds, from: self.view))!
            self.assetTransitionController.initiallyInteractive = false
            self.assetTransitionController.animationItems = [item]
            imageView.isHidden = true
            self.selectedImageView = imageView
            self.performSegue(withIdentifier: kSegueIdentifier, sender: imageView.image)
        }
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let imageVC = segue.destination as? ImageViewController, let image = sender as? UIImage {
            self.selectedImageView?.isHidden = true
            imageVC.image = image
        }
    }

}

