import UIKit
import SnapKit

class RecordDetailViewController: RideThisViewController {
    weak var coordinator: RecordDetailCoordinator?
    var viewModel: RecordDetailViewModel!
    
    // 로고
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logoTransparent"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var record: RecordModel?
    
    // 기록 뷰 선언
    private let durationRecord = RecordContainer(title: "Start ~ End", recordText: "00:00 ~ 23:59", view: "record")
    private let timeRecord = RecordContainer(title: "Time", recordText: "00:00", view: "record")
    private let distanceRecord = RecordContainer(title: "Distance", recordText: "0 km", view: "record")
    private let SpeedRecord = RecordContainer(title: "Speed", recordText: "0 km/h", view: "record")
    private let calorieRecord = RecordContainer(title: "Calories", recordText: "0 kcal", view: "record")
    
    private let detailTitleLabel = RideThisLabel(fontType: .recordInfoTitle, fontColor: .black, text: "운동 세부사항")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureView()
    }
    
    func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(detailTitleLabel)
        
        // 기록 뷰 추가
        view.addSubview(durationRecord)
        view.addSubview(timeRecord)
        view.addSubview(distanceRecord)
        view.addSubview(SpeedRecord)
        view.addSubview(calorieRecord)
    }
    
    // MARK: - 제약조건
    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(170)
        }
        
        detailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(16) // 로고 이미지 추가 후 수정
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // 기록 뷰 제약조건
        durationRecord.snp.makeConstraints { dura in
            dura.top.equalTo(detailTitleLabel.snp.bottom).offset(15)
            dura.left.equalToSuperview().offset(20)
            dura.right.equalToSuperview().offset(-20)
            dura.height.equalTo(110)
        }
        
        timeRecord.snp.makeConstraints { time in
            time.top.equalTo(durationRecord.snp.bottom).offset(15)
            time.left.equalToSuperview().offset(20)
            time.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            time.height.equalTo(110)
        }
        
        distanceRecord.snp.makeConstraints { dist in
            dist.top.equalTo(durationRecord.snp.bottom).offset(15)
            dist.left.equalTo(timeRecord.snp.right).offset(10)
            dist.right.equalToSuperview().offset(-20)
            dist.height.equalTo(110)
        }
        
        SpeedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(timeRecord.snp.bottom).offset(15)
            speed.left.equalToSuperview().offset(20)
            speed.width.equalToSuperview().multipliedBy(0.5).offset(-25)
            speed.height.equalTo(110)
        }
        
        calorieRecord.snp.makeConstraints { cal in
            cal.top.equalTo(distanceRecord.snp.bottom).offset(15)
            cal.left.equalTo(SpeedRecord.snp.right).offset(10)
            cal.right.equalToSuperview().offset(-20)
            cal.height.equalTo(110)
        }
    }
    
    func configureView() {
        self.title = viewModel.title
        
        durationRecord.updateRecordText(text: viewModel.durationText)
        timeRecord.updateRecordText(text: viewModel.timeText)
        distanceRecord.updateRecordText(text: viewModel.distanceText)
        SpeedRecord.updateRecordText(text: viewModel.speedText)
        calorieRecord.updateRecordText(text: viewModel.calorieText)
    }
}
