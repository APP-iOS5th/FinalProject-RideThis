//
//  Coordinator.swift
//  RideThis
//
//  Created by SeongKook on 8/27/24.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
}
