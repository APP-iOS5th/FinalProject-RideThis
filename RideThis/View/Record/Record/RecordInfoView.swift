import UIKit
import SnapKit

class RecordInfoView: RideThisContainer {
    // 레이블과 Separator 선언
    let titleLabel: RideThisLabel
    let separator: RideThisSeparator
    var recordLabel: RideThisLabel
    
    // 초기화 메서드
    init(title: String, recordText: String) {
        // 레이블과 Separator 초기화
        self.titleLabel = RideThisLabel(fontType: .sectionTitle, fontColor: .recordTitleColor, text: title)
        self.separator = RideThisSeparator()
        // Timer인 경우 크기 조절
        if title == "Timer" {
            self.recordLabel = RideThisLabel(fontType: .timerText, text: recordText)
        } else {
            self.recordLabel = RideThisLabel(fontType: .recordInfoTitle, text: recordText)
        }
        
        super.init(frame: .zero)
        
        // 서브뷰 추가
        self.addSubview(titleLabel)
        self.addSubview(separator)
        self.addSubview(recordLabel)
        
        // 제약조건 설정
        titleLabel.snp.makeConstraints { label in
            label.top.equalTo(self.snp.top).offset(10)
            label.centerX.equalTo(self.snp.centerX)
        }
        
        separator.snp.makeConstraints { seperator in
            seperator.top.equalTo(self.titleLabel.snp.bottom).offset(7)
            seperator.left.equalTo(self.titleLabel.snp.left).offset(10)
            seperator.right.equalTo(self.titleLabel.snp.right).offset(-10)
        }
        
        recordLabel.snp.makeConstraints { label in
            label.top.equalTo(self.separator.snp.bottom).offset(10)
            label.centerX.equalTo(self.snp.centerX)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
