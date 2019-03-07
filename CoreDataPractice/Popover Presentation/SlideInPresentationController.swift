//
//  SlideInPresentationController.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 2/4/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {

  //1
  // MARK: - Properties
  private var direction: PresentationDirection
  fileprivate var dimmingView: UIView!
  
  //2
  init(presentedViewController: UIViewController,
       presenting presentingViewController: UIViewController?,
       direction: PresentationDirection) {
    self.direction = direction
    
    //3
    super.init(presentedViewController: presentedViewController,
               presenting: presentingViewController)
    setupDimmingView()
  }
  
  func setupDimmingView() {
    let blur = UIBlurEffect(style: .dark)
    dimmingView = UIVisualEffectView(effect: blur)
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.alpha = 0.0
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  @objc dynamic func handleTap(recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true)
  }
  
  override func presentationTransitionWillBegin() {
    
    // 1
    containerView?.insertSubview(dimmingView, at: 0)
    
    // 2
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                     options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                     options: [], metrics: nil, views: ["dimmingView": dimmingView]))
    
    //3
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }

  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }

  override func containerViewWillLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
    presentedView?.layer.cornerRadius = 8
  }

  override func size(forChildContentContainer container: UIContentContainer,
                     withParentContainerSize parentSize: CGSize) -> CGSize {
    switch direction {
    case .left, .right:
      return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
    case .bottom, .top:
      return CGSize(width: parentSize.width, height: parentSize.height*(0.5))
    }
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    
    //1
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController,
                      withParentContainerSize: containerView!.bounds.size)
    
    //2
    switch direction {
    case .right:
      frame.origin.x = containerView!.frame.width*(1.0/3.0)
    case .bottom:
      frame.origin.y = containerView!.frame.height*(0.2)
      frame.origin.x = (containerView!.frame.width - frame.size.width) / 2
    default:
      frame.origin = .zero
    }
    
    return frame
  }

}
