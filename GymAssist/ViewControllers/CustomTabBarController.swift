//
//  CustomTabBarController.swift
//  GymAssist
//
//  Created by Александр on 20.01.2022.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = initialIndex
    }
    
}
