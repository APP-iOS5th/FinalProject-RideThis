//
//  DistancSelectionViewController.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import UIKit

class DistanceSelectionViewController: RideThisViewController {
    
    private let titleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "목표 Km")
    
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: setupUI
    private func setupUI() {
        self.title = "경쟁하기"
        
        setupNavigationBar()
        setupLayout()
    }
    
    // MARK: NavigationBar
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    // MARK: Layout
    private func setupLayout() {
        let safeArea = self.view.safeAreaLayoutGuide
        
        self.view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { title in
            title.top.equalTo(safeArea.snp.bottom).offset(10)
            title.left.equalTo(safeArea.snp.left).offset(20)
        }
    }
}

#Preview {
    UINavigationController(rootViewController: DistanceSelectionViewController())
}
