//
//  DistancSelectionViewController.swift
//  RideThis
//
//  Created by SeongKook on 8/13/24.
//

import UIKit
import SnapKit
import Combine

class DistanceSelectionViewController: RideThisViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private let titleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "목표 Km")
    
    private let distanceButton: UIButton = {
        let button = UIButton(type: .custom)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        config.baseForegroundColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        var titleAttr = AttributedString("5KM")
        titleAttr.font = .systemFont(ofSize: 24, weight: .bold)
        config.attributedTitle = titleAttr
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
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
        self.view.addSubview(distanceButton)
        
        titleLabel.snp.makeConstraints { title in
            title.top.equalTo(safeArea.snp.top).offset(20)
            title.left.equalTo(safeArea.snp.left).offset(20)
        }
        
        distanceButton.snp.makeConstraints { btn in
            btn.top.equalTo(titleLabel.snp.bottom).offset(20)
            btn.left.equalTo(safeArea.snp.left).offset(20)
            btn.right.equalTo(safeArea.snp.right).offset(-20)
        }
    }
}

#Preview {
    UINavigationController(rootViewController: DistanceSelectionViewController())
}
