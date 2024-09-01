//
//  RecordContainerView.swift
//  RideThis
//
//  Created by 황승혜 on 8/13/24.
//  컴포넌트 분리

import UIKit
import SnapKit

class RecordContainerView: UIView {
    // 5개의 RecordInfoView 생성
    let timerView = RecordInfoView(title: "Timer", recordText: "00:00")
    let cadenceView = RecordInfoView(title: "Cadence", recordText: "0 RPM")
    let speedView = RecordInfoView(title: "Speed", recordText: "0 km/h")
    let distanceView = RecordInfoView(title: "Distance", recordText: "0 km")
    let calorieView = RecordInfoView(title: "Calories", recordText: "0 kcal")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.addSubview(timerView)
        self.addSubview(cadenceView)
        self.addSubview(speedView)
        self.addSubview(distanceView)
        self.addSubview(calorieView)
        
        // 제약조건 설정
        timerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(150)
        }
        
        cadenceView.snp.makeConstraints { make in
            make.top.equalTo(timerView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            make.height.equalTo(110)
        }
        
        speedView.snp.makeConstraints { make in
            make.top.equalTo(timerView.snp.bottom).offset(15)
            make.left.equalTo(cadenceView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(110)
        }
        
        distanceView.snp.makeConstraints { make in
            make.top.equalTo(cadenceView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            make.height.equalTo(110)
        }
        
        calorieView.snp.makeConstraints { make in
            make.top.equalTo(speedView.snp.bottom).offset(10)
            make.left.equalTo(distanceView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(110)
        }
    }
}
