//
//  Animator.swift
//  ToDoApp
//
//

import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    var originFrame = CGRect.zero
    private let duration = 0.8

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let initialFrame = originFrame
        let finalFrame = toView.frame

        let xScaleFactor = initialFrame.width / finalFrame.width
        let yScaleFactor = initialFrame.height / finalFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        toView.transform = scaleTransform
        toView.center = CGPoint(
            x: initialFrame.midX,
            y: initialFrame.midY
        )

        containerView.addSubview(toView)
        containerView.bringSubviewToFront(toView)

        UIView.animate(
            withDuration: duration,
            animations: {
                toView.transform = .identity
                toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            },
            completion: { _ in
                transitionContext.completeTransition(true)
            }
        )
    }

}
