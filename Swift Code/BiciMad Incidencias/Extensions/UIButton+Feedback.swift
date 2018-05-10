//
//  UIButton+Feedback.swift
//  desappstre framework
//
//  Created by Adolfo on 19/05/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

public extension UIButton
{
    public func selectedFeedback() -> Void
    {
        AudioServicesPlaySystemSound(1104)
	}

	public func unselectedFeedback() -> Void
	{
        AudioServicesPlaySystemSound(1104)
	}
}
