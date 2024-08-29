//
//  CountViewController.swift
//  RideThis
//
//  Created by SeongKook on 8/14/24.
//

import UIKit
import SnapKit
import Combine

protocol CountViewControllerDelegate: AnyObject {
    func countdownFinish()
}

class CountViewController: RideThisViewController {
    
    weak var countDelegate: CountViewControllerDelegate?
    
    private var viewModel = CountViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let countLabel = RideThisLabel(fontType: .countDownSize, fontColor: .primaryColor, text: "5")
    private let countInfoLabel = RideThisLabel(fontType: .classification, fontColor: .black, text: "경쟁을 떠나 안전이 최우선입니다.")


    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
    }
    
    // MARK: ViewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.startCountdown()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        setupLayout()
    }
    
    // MARK: SetupLayout
    private func setupLayout() {
        self.view.addSubview(countLabel)
        self.view.addSubview(countInfoLabel)
        
        countLabel.snp.makeConstraints{ [weak self] count in
            guard let self = self else { return }
            count.centerX.equalTo(self.view.snp.centerX)
            count.centerY.equalTo(self.view.snp.centerY)
        }
        
        countInfoLabel.snp.makeConstraints{ [weak self] label in
            guard let self = self else { return }
            label.centerX.equalTo(self.view.snp.centerX)
            label.top.equalTo(countLabel.snp.bottom)
        }
    }
    
    // MARK: SetupBinding Data
    private func setupBinding() {
        viewModel.$currentCount
            .receive(on: RunLoop.main)
            .sink { [weak self] newCount in
                self?.countLabel.text = "\(newCount)"
                
                if newCount == 0 {
                    self?.countDelegate?.countdownFinish()
                }
            }
            .store(in: &cancellables)
    }
}
