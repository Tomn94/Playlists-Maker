//
//  DismissSegue.swift
//  Playlist Maker
//
//  Created by Tomn on 31/08/2017.
//  Copyright © 2017 Thomas NAUDET. All rights reserved.
//

import UIKit

/// Dismiss view controller in Storyboard
class DismissSegue: UIStoryboardSegue {

    override func perform() {
        source.presentingViewController?.dismiss(animated: true)
    }
    
}
