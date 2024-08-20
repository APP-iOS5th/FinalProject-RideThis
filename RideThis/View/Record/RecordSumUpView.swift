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
    
    // 커스텀 타이틀
    private let customTitleLabel = RideThisLabel(fontType: .title, fontColor: .black, text: "운동기록 요약")
    
    // 기록 뷰 선언
    private let timerRecord = RecordContainer(title: "Timer", recordText: "00:00", view: "summary")
    private let cadenceRecord = RecordContainer(title: "Cadence", recordText: "0 RPM", view: "summary")
    private let speedRecord = RecordContainer(title: "Speed", recordText: "0 km/h", view: "summary")
    private let distanceRecord = RecordContainer(title: "Distance", recordText: "0 km", view: "summary")
    private let calorieRecord = RecordContainer(title: "Calories", recordText: "0 kcal", view: "summary")
    
    // 버튼 선언
    let cancelButton = RideThisButton(buttonTitle: "취소")
    let saveButton = RideThisButton(buttonTitle: "저장")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        // 기록 뷰 추가
        self.view.addSubview(timerRecord)
        self.view.addSubview(cadenceRecord)
        self.view.addSubview(speedRecord)
        self.view.addSubview(distanceRecord)
        self.view.addSubview(calorieRecord)

        // 버튼 추가
        self.view.addSubview(cancelButton)
        self.view.addSubview(saveButton)
        cancelButton.backgroundColor = .black
        
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.cancelSaveRecording()
        }, for: .touchUpInside)
        
        // 뷰 모델에서 기록 저장 취소 트리거 처리
        viewModel.onCancelSaveRecording = { [weak self] in
            // 저장 없이 기록 뷰로 이동
            self?.navigateToRecordView()
        }
        
        saveButton.addAction(UIAction { [weak self] _ in
            // TODO: - 미로그인 상태일 때 로그인 팝업
            self?.showAlert(alertTitle: "기록 저장", msg: "기록을 저장하시겠습니까?", confirm: "저장"
            ) {
                self?.viewModel.saveRecording()
            }
        }, for: .touchUpInside)
        
        viewModel.onSaveRecroding = { [weak self] in
            // TODO: - 저장 후 마이페이지 뷰-기록으로 이동인지 기록 뷰로 이동인지 확인 필요
            // 일단 기록 뷰로 이동
            self?.navigateToRecordView()
        }
    
        // 기록 뷰 제약조건
        timerRecord.snp.makeConstraints { timer in
            timer.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            timer.left.equalToSuperview().offset(20)
            timer.right.equalToSuperview().offset(-20)
            timer.height.equalTo(100)
        }
        
        cadenceRecord.snp.makeConstraints { cadence in
            cadence.top.equalTo(timerRecord.snp.bottom).offset(20)
            cadence.left.equalToSuperview().offset(20)
            cadence.right.equalToSuperview().offset(-20)
            cadence.height.equalTo(100)
        }
        
        speedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(cadenceRecord.snp.bottom).offset(20)
            speed.left.equalToSuperview().offset(20)
            speed.right.equalToSuperview().offset(-20)
            speed.height.equalTo(100)
        }

        distanceRecord.snp.makeConstraints { distance in
            distance.top.equalTo(speedRecord.snp.bottom).offset(20)
            distance.left.equalToSuperview().offset(20)
            distance.right.equalToSuperview().offset(-20)
            distance.height.equalTo(100)
        }

        calorieRecord.snp.makeConstraints { calorie in
            calorie.top.equalTo(distanceRecord.snp.bottom).offset(20)
            calorie.left.equalToSuperview().offset(20)
            calorie.right.equalToSuperview().offset(-20)
            calorie.height.equalTo(100)
        }
        
        // 버튼 제약조건
        cancelButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieRecord.snp.bottom).offset(25)
            btn.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
            btn.right.equalTo(self.view.snp.centerX).offset(-10)
        }
        
        saveButton.snp.makeConstraints { [weak self] btn in
            guard let self = self else { return }
            btn.top.equalTo(calorieRecord.snp.bottom).offset(25)
            btn.left.equalTo(self.view.snp.centerX).offset(10)
            btn.right.equalTo(self.view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
    }
    
    private func navigateToRecordView() {
        let recordViewController = RecordView()
        self.navigationController?.pushViewController(recordViewController, animated: true) // 기록 화면으로 이동
    }
    
    // MARK: Navigation Bar
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // 커스텀 타이틀 레이블을 왼쪽 바 버튼 아이템으로 설정
        let leftBarButtonItem = UIBarButtonItem(customView: customTitleLabel)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
}

#Preview {
    UINavigationController(rootViewController: RecordSumUpView())
}
