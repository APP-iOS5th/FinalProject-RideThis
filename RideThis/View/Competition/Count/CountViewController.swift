//
//  CountViewController.swift
//  RideThis
//
//  Created by SeongKook on 8/14/24.
//

import UIKit
import SnapKit
import Combine

class CountViewController: RideThisViewController {
    
    private let countLabel = RideThisLabel(fontType: .countDownSize, fontColor: .primaryColor, text: "5")
    private var viewModel = CountViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        self.viewModel.startCountdown()
        setupBinding()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        setupLayout()
    }
    
    // MARK: SetupLayout
    private func setupLayout() {
        self.view.addSubview(countLabel)
        
        countLabel.snp.makeConstraints{ [weak self] count in
            guard let self = self else { return }
            count.centerX.equalTo(self.view.snp.centerX)
            count.centerY.equalTo(self.view.snp.centerY)
        }
    }
    
    // MARK: SetupBinding Data
    private func setupBinding() {
        viewModel.$currentCount
            .receive(on: RunLoop.main)
            .sink { [weak self] newCount in
                self?.countLabel.text = "\(newCount)"
            }
            .store(in: &cancellables)
    }
}


#Preview {
    UINavigationController(rootViewController: CountViewController())
}
