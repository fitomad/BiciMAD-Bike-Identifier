//
//  UIButton+Feedback.swift
//  desappstre framework
//
//  Created by Adolfo on 19/05/15.
//  Copyright (c) 2015 Desappstre Studio. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public extension UIButton
{
	public func selectedFeedback() -> Void
	{
		guard let asset = NSDataAsset(name:"Selected"),
			  let player = try? AVAudioPlayer(data: asset.data, fileTypeHint: "m4a")
		else
		{
			return
		}

    	player.play()
	}

	public func unselectedFeedback() -> Void
	{
		guard let asset = NSDataAsset(name:"Unselected"),
			  let player = try? AVAudioPlayer(data: asset.data, fileTypeHint: "m4a")
		else
		{
			return
		}

    	player.play()
	}
}
