import UIKit
import SnapKit

class DailyRecordView: UIView {
    private let containerView = UIView()
    private let dateLabel = RideThisLabel(fontType: .defaultSize, fontColor: .gray)
    private let distanceLabel = RideThisLabel(fontType: .profileFont, fontColor: .black)
    private let profileImageView = UIImageView()
    private let arrowImageView = UIImageView()
    
    var onTap: (() -> Void)?
    
    private let imageCache = ImageCache.shared
    private var imageLoadTask: URLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(arrowImageView)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 20 
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .gray
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        containerView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(80)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(16)
            make.top.equalToSuperview().offset(20)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.left.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(6)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func configure(with record: RecordModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = dateFormatter.string(from: record.record_start_time ?? Date())
        distanceLabel.text = "\(String(format: "%.3f", record.record_distance)) Km (\(record.record_competetion_status == true ? "경쟁" : "기록"))"
        
        // 프로필 이미지 로드
        loadProfileImage(userId: record.user_id)
    }
    
    private func loadProfileImage(userId: String) {
        // 먼저 캐시에서 이미지를 확인
        if let cachedImage = imageCache.image(forKey: userId) {
            self.profileImageView.image = cachedImage
            return
        }
        
        // 플레이스홀더 이미지 설정
        self.profileImageView.image = UIImage(named: "bokdonge")
        
        let firebaseService = FireBaseService()
        firebaseService.loadImage(userId: userId) { [weak self] url in
            guard let url = url else {
                DispatchQueue.main.async {
                    self?.profileImageView.image = UIImage(named: "bokdonge")
                }
                return
            }
            
            // 이전 작업 취소
            self?.imageLoadTask?.cancel()
            
            // 새 이미지 다운로드 작업
            self?.imageLoadTask = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    // 이미지 크기 최적화
                    let resizedImage = self?.resizeImage(image, targetSize: CGSize(width: 80, height: 80))
                    
                    DispatchQueue.main.async {
                        self?.profileImageView.image = resizedImage
                        // 캐시에 이미지 저장
                        self?.imageCache.setImage(resizedImage ?? image, forKey: userId)
                    }
                }
            }
            self?.imageLoadTask?.resume()
        }
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    @objc private func viewTapped() {
        onTap?()
    }
}
