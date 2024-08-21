//
//  SummaryRecordViewController.swift
//  RideThis
//
//  Created by SeongKook on 8/16/24.
//

import UIKit
import SnapKit

class SummaryRecordViewController: RideThisViewController {
    
    private let viewModel: SummaryRecordViewModel
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let timerRecord = RecordContainer(title: "Timer", recordText: "00:00", view: "summary")
    private let cadenceRecord = RecordContainer(title: "Cadence", recordText: "0 RPM", view: "summary")
    private let speedRecord = RecordContainer(title: "Speed", recordText: "0 km/h", view: "summary")
    private let distanceRecord = RecordContainer(title: "Distance", recordText: "0 km", view: "summary")
    private let calorieRecord = RecordContainer(title: "Calories", recordText: "0 kcal", view: "summary")
    
    private let confirmButton = RideThisButton(buttonTitle: "확인", height: 50)
    
    // MARK: 초기화 및 데이터 바인딩
    init(timer: String, cadence: Double, speed: Double, distance: Double, calorie: Double, startTime: Date, endTime: Date) {
        self.viewModel = SummaryRecordViewModel(timer: timer, cadence: cadence, speed: speed, distance: distance, calorie: calorie, startTime: startTime, endTime: endTime)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBinding()
        setupAction()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        self.title = "경쟁요약"
        self.navigationItem.hidesBackButton = true
        
        setupLayout()
    }
    
    // MARK: SetupBinding Data
    private func setupBinding() {
        timerRecord.updateRecordText(text: viewModel.timer)
        cadenceRecord.updateRecordText(text: "\(viewModel.cadence.formattedWithThousandsSeparator()) RPM")
        speedRecord.updateRecordText(text: "\(viewModel.speed.formattedWithThousandsSeparator()) Km/h")
        distanceRecord.updateRecordText(text: "\(viewModel.distance.formattedWithThousandsSeparator()) Km")
        calorieRecord.updateRecordText(text: "\(viewModel.calorie.formattedWithThousandsSeparator()) Kcal")
    }
    
    // MARK: Setup Layout
    private func setupLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(timerRecord)
        contentView.addSubview(cadenceRecord)
        contentView.addSubview(speedRecord)
        contentView.addSubview(distanceRecord)
        contentView.addSubview(calorieRecord)
        self.view.addSubview(confirmButton)
        
        let safeArea = self.view.safeAreaLayoutGuide
        
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(safeArea)
            make.bottom.equalTo(confirmButton.snp.top).offset(-19)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(timerRecord.snp.top)
            make.bottom.equalTo(calorieRecord.snp.bottom)
        }
        
        timerRecord.snp.makeConstraints { timer in
            timer.top.equalTo(contentView.snp.top).offset(20)
            timer.left.equalToSuperview().offset(20)
            timer.right.equalToSuperview().offset(-20)
            timer.height.equalTo(100)
        }
        
        cadenceRecord.snp.makeConstraints { cadence in
            cadence.top.equalTo(timerRecord.snp.bottom).offset(13)
            cadence.left.equalToSuperview().offset(20)
            cadence.right.equalToSuperview().offset(-20)
            cadence.height.equalTo(100)
        }
        
        speedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(cadenceRecord.snp.bottom).offset(13)
            speed.left.equalToSuperview().offset(20)
            speed.right.equalToSuperview().offset(-20)
            speed.height.equalTo(100)
        }

        distanceRecord.snp.makeConstraints { distance in
            distance.top.equalTo(speedRecord.snp.bottom).offset(13)
            distance.left.equalToSuperview().offset(20)
            distance.right.equalToSuperview().offset(-20)
            distance.height.equalTo(100)
        }

        calorieRecord.snp.makeConstraints { calorie in
            calorie.top.equalTo(distanceRecord.snp.bottom).offset(13)
            calorie.left.equalToSuperview().offset(20)
            calorie.right.equalToSuperview().offset(-20)
            calorie.height.equalTo(100)
        }
        
        confirmButton.snp.makeConstraints { btn in
            btn.bottom.equalTo(safeArea.snp.bottom).offset(-19)
            btn.centerX.equalTo(self.view.snp.centerX)
            btn.width.equalTo(210)
        }
    }
    
    // MARK: Setup Action
    private func setupAction() {
        confirmButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let ResultRankingVC = ResultRankingViewController(distance: self.viewModel.distance)
            self.navigationController?.pushViewController(ResultRankingVC, animated: true)
        }, for: .touchUpInside)
    }
}

#Preview {
    UINavigationController(rootViewController: SummaryRecordViewController(timer: "11:11", cadence: 12.3, speed: 12.1, distance: 1.2, calorie: 123.2, startTime: Date(), endTime: Date()))
}
