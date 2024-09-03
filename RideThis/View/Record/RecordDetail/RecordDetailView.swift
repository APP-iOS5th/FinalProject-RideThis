import UIKit
import SnapKit

class RecordDetailView: RideThisViewController {
    weak var coordinator: RecordDetailCoordinator?
    var viewModel: RecordDetailViewModel!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
        
        setupScrollView()
        setupViews()
        setupConstraints()
        configureView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    }
    
    func setupViews() {
        [logoImageView, detailTitleLabel, durationRecord, timeRecord, distanceRecord, SpeedRecord, calorieRecord].forEach {
            contentView.addSubview($0)
        }
    }
    
    // MARK: - 제약조건
    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(16)
            make.centerX.equalTo(contentView)
            make.width.height.equalTo(170)
        }
        
        detailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(16)
            make.leading.equalTo(contentView).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
        }
        
        // 기록 뷰 제약조건
        durationRecord.snp.makeConstraints { dura in
            dura.top.equalTo(detailTitleLabel.snp.bottom).offset(15)
            dura.left.equalTo(contentView).offset(20)
            dura.right.equalTo(contentView).offset(-20)
            dura.height.equalTo(110)
        }
        
        timeRecord.snp.makeConstraints { time in
            time.top.equalTo(durationRecord.snp.bottom).offset(15)
            time.left.equalTo(contentView).offset(20)
            time.width.equalTo(contentView).multipliedBy(0.5).offset(-25)
            time.height.equalTo(110)
        }
        
        distanceRecord.snp.makeConstraints { dist in
            dist.top.equalTo(durationRecord.snp.bottom).offset(15)
            dist.left.equalTo(timeRecord.snp.right).offset(10)
            dist.right.equalTo(contentView).offset(-20)
            dist.height.equalTo(110)
        }
        
        SpeedRecord.snp.makeConstraints { speed in
            speed.top.equalTo(timeRecord.snp.bottom).offset(15)
            speed.left.equalTo(contentView).offset(20)
            speed.width.equalTo(contentView).multipliedBy(0.5).offset(-25)
            speed.height.equalTo(110)
        }
        
        calorieRecord.snp.makeConstraints { cal in
            cal.top.equalTo(distanceRecord.snp.bottom).offset(15)
            cal.left.equalTo(SpeedRecord.snp.right).offset(10)
            cal.right.equalTo(contentView).offset(-20)
            cal.height.equalTo(110)
            cal.bottom.equalTo(contentView).offset(-20) // 마지막 요소의 하단에 여백 추가
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
