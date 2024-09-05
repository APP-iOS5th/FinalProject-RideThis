import UIKit
import SnapKit

class RecordContainer: RideThisContainer {
    
    let titleLabel: RideThisLabel
    let separator: RideThisSeparator
    var recordLabel: RideThisLabel
    
    init(title: String, recordText: String, view: String) {
        // 레이블과 Separator 초기화
        self.separator = RideThisSeparator()
        
        switch view {
        case "record":
            // Timer인 경우 크기 조절
            if title == "Timer" {
                self.titleLabel = RideThisLabel(fontType: .recordInfoTitle, fontColor: .recordTitleColor, text: title)
                self.recordLabel = RideThisLabel(fontType: .timerText, text: recordText)
            } else {
                self.titleLabel = RideThisLabel(fontType: .recordTitle, fontColor: .recordTitleColor, text: title)
                self.recordLabel = RideThisLabel(fontType: .recordInfo, text: recordText)
            }
        case "summary":
            self.titleLabel = RideThisLabel(fontType: .classification, fontColor: .recordTitleColor, text: title)
            self.recordLabel = RideThisLabel(fontType: .summaryInfo, text: recordText)
        default:
            self.titleLabel = RideThisLabel(fontType: .defaultSize, text: "")
            self.recordLabel = RideThisLabel(fontType: .defaultSize, text: "")
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
            seperator.centerX.equalTo(self.snp.centerX)
            seperator.width.equalTo(30)
        }
        
        recordLabel.snp.makeConstraints { label in
            label.top.equalTo(self.separator.snp.bottom).offset(10)
            label.centerX.equalTo(self.snp.centerX)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // recordLabel의 텍스트를 변경하는 메서드
    func updateRecordText(text: String) {
        self.recordLabel.text = text
    }

}
