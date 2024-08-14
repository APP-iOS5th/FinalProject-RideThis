//
//  RecordSumUpView.swift
//  RideThis
//
//  Created by 황승혜 on 8/13/24.
//  기록 요약 뷰

import UIKit
import SnapKit

class RecordSumUpView: RideThisViewController {
    let viewModel = RecordViewModel()
    
    // 컨테이너 선언
    let timerContainer = RideThisContainer()
    let cadenceContainer = RideThisContainer()
    let speedContainer = RideThisContainer()
    let distanceContainer = RideThisContainer()
    let calorieContainer = RideThisContainer()
    
    // 타이틀 레이블
    let timerLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .recordTitleColor, text: "Timer")
    let cadenceLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .recordTitleColor, text: "Cadence")
    let speedLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .recordTitleColor, text: "Speed")
    let distanceLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .recordTitleColor, text: "Distance")
    let calorieLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .recordTitleColor, text: "Calories")
    
    // Seperator 선언
    let timerSeperator = RideThisSeparator()
    let cadenceSeperator = RideThisSeparator()
    let speedSeperator = RideThisSeparator()
    let distanceSeperator = RideThisSeparator()
    let calorieSeperator = RideThisSeparator()
    
    // 기록 레이블
    let timerRecordLabel = RideThisLabel(fontType: .recordInfoTitle, text: "00:00")
    let cadenceRecordLabel = RideThisLabel(fontType: .recordInfoTitle, text: "0 RPM")
    let speedRecordLabel = RideThisLabel(fontType: .recordInfoTitle, text: "0 km/h")
    let distanceRecordLabel = RideThisLabel(fontType: .recordInfoTitle, text: "0 km")
    let calorieRecordLabel = RideThisLabel(fontType: .recordInfoTitle, text: "0 kcal")
    
    // 버튼 선언
    let cancelButton = RideThisButton(buttonTitle: "취소")
    let saveButton = RideThisButton(buttonTitle: "저장")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 대형 타이틀 활성화
        // TODO: - UI 맞춰서 수정할 것
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .inline
        self.navigationItem.title = "운동기록 요약"
        
        // 컨테이너 추가
        self.view.addSubview(timerContainer)
        self.view.addSubview(cadenceContainer)
        self.view.addSubview(speedContainer)
        self.view.addSubview(distanceContainer)
        self.view.addSubview(calorieContainer)
        
        // 레이블 추가
        self.timerContainer.addSubview(timerLabel)
        self.cadenceContainer.addSubview(cadenceLabel)
        self.speedContainer.addSubview(speedLabel)
        self.distanceContainer.addSubview(distanceLabel)
        self.calorieContainer.addSubview(calorieLabel)
        
        // Separator 추가
        self.timerContainer.addSubview(timerSeperator)
        self.cadenceContainer.addSubview(cadenceSeperator)
        self.speedContainer.addSubview(speedSeperator)
        self.distanceContainer.addSubview(distanceSeperator)
        self.calorieContainer.addSubview(calorieSeperator)
        
        // 기록 레이블 추가
        self.timerContainer.addSubview(timerRecordLabel)
        self.cadenceContainer.addSubview(cadenceRecordLabel)
        self.speedContainer.addSubview(speedRecordLabel)
        self.distanceContainer.addSubview(distanceRecordLabel)
        self.calorieContainer.addSubview(calorieRecordLabel)
        
        // 버튼 추가
        self.view.addSubview(cancelButton)
        self.view.addSubview(saveButton)
        cancelButton.backgroundColor = .black
        
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.cancelSaveRecording()
        }, for: .touchUpInside)
        saveButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.saveRecording()
        }, for: .touchUpInside)
        
        timerContainer.snp.makeConstraints { [weak self] cont in
            guard let self = self else { return }
            cont.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            cont.height.equalTo(100)
            cont.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            cont.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        cadenceContainer.snp.makeConstraints { [weak self] cont in
            guard let self = self else { return }
            cont.top.equalTo(timerContainer.snp.bottom).offset(15)
            cont.height.equalTo(100)
            cont.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            cont.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        speedContainer.snp.makeConstraints { [weak self] cont in
            guard let self = self else { return }
            cont.top.equalTo(cadenceContainer.snp.bottom).offset(15)
            cont.height.equalTo(100)
            cont.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            cont.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        distanceContainer.snp.makeConstraints { [weak self] cont in
            guard let self = self else { return }
            cont.top.equalTo(speedContainer.snp.bottom).offset(15)
            cont.height.equalTo(100)
            cont.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            cont.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        calorieContainer.snp.makeConstraints { [weak self] cont in
            guard let self = self else { return }
            cont.top.equalTo(distanceContainer.snp.bottom).offset(15)
            cont.height.equalTo(100)
            cont.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            cont.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        // 레이블 제약조건
        timerLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.timerContainer.snp.top).offset(10)
            label.centerX.equalTo(self.timerContainer.snp.centerX)
        }
        
        cadenceLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.cadenceContainer.snp.top).offset(10)
            label.centerX.equalTo(self.cadenceContainer.snp.centerX)
        }
        
        speedLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.speedContainer.snp.top).offset(10)
            label.centerX.equalTo(self.speedContainer.snp.centerX)
        }
        
        distanceLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.distanceContainer.snp.top).offset(10)
            label.centerX.equalTo(self.distanceContainer.snp.centerX)
        }
        
        calorieLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.calorieContainer.snp.top).offset(10)
            label.centerX.equalTo(self.calorieContainer.snp.centerX)
        }
        
        // Seperator 제약조건
        timerSeperator.snp.makeConstraints { [weak self] seperator in
            guard let self = self else { return }
            seperator.top.equalTo(self.timerLabel.snp.bottom).offset(5)
            seperator.left.equalTo(self.timerLabel.snp.left).offset(10)
            seperator.right.equalTo(self.timerLabel.snp.right).offset(-10)
        }
        
        cadenceSeperator.snp.makeConstraints { [weak self] seperator in
            guard let self = self else { return }
            seperator.top.equalTo(self.cadenceLabel.snp.bottom).offset(7)
            seperator.left.equalTo(self.cadenceLabel.snp.left).offset(10)
            seperator.right.equalTo(self.cadenceLabel.snp.right).offset(-10)
        }
        
        speedSeperator.snp.makeConstraints { [weak self] seperator in
            guard let self = self else { return }
            seperator.top.equalTo(self.speedLabel.snp.bottom).offset(7)
            seperator.left.equalTo(self.speedLabel.snp.left).offset(10)
            seperator.right.equalTo(self.speedLabel.snp.right).offset(-10)
        }
        
        distanceSeperator.snp.makeConstraints { [weak self] seperator in
            guard let self = self else { return }
            seperator.top.equalTo(self.distanceLabel.snp.bottom).offset(7)
            seperator.left.equalTo(self.distanceLabel.snp.left).offset(10)
            seperator.right.equalTo(self.distanceLabel.snp.right).offset(-10)
        }
        
        calorieSeperator.snp.makeConstraints { [weak self] seperator in
            guard let self = self else { return }
            seperator.top.equalTo(self.calorieLabel.snp.bottom).offset(7)
            seperator.left.equalTo(self.calorieLabel.snp.left).offset(10)
            seperator.right.equalTo(self.calorieLabel.snp.right).offset(-10)
        }
        
        // 기록 레이블 제약조건
        timerRecordLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.timerSeperator.snp.bottom).offset(5)
            label.centerX.equalTo(self.timerContainer.snp.centerX)
        }
        
        cadenceRecordLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.cadenceSeperator.snp.bottom).offset(10)
            label.centerX.equalTo(self.cadenceContainer.snp.centerX)
        }
        
        speedRecordLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.speedSeperator.snp.bottom).offset(10)
            label.centerX.equalTo(self.speedContainer.snp.centerX)
        }
        
        distanceRecordLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.distanceSeperator.snp.bottom).offset(10)
            label.centerX.equalTo(self.distanceContainer.snp.centerX)
        }
        
        calorieRecordLabel.snp.makeConstraints { [weak self] label in
            guard let self = self else { return }
            label.top.equalTo(self.calorieSeperator.snp.bottom).offset(10)
            label.centerX.equalTo(self.calorieContainer.snp.centerX)
        }
        
        // 버튼 제약조건
        cancelButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieContainer.snp.bottom).offset(25)
            btn.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            btn.right.equalTo(self.view.snp.centerX).offset(-10)
        }
        
        saveButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieContainer.snp.bottom).offset(25)
            btn.left.equalTo(self.view.snp.centerX).offset(10)
            btn.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
    }
}

#Preview {
    UINavigationController(rootViewController: RecordSumUpView())
}
