//
//  DistancSelectionViewController.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import UIKit

class DistanceSelectionViewController: RideThisViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        self.title = "경쟁하기"
        self.view.backgroundColor = .primaryBackgroundColor
    }
}
