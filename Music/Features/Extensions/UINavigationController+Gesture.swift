//
//  UINavigationController+Gesture.swift
//  Music
//
//  Created by Rasmus Krämer on 07.09.23.
//

#if canImport(UIKit)

import Foundation
import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

#endif
