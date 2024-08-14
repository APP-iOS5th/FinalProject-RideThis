import UIKit
import DGCharts

class GraphCollectionViewCell: UICollectionViewCell {
    let lineChartView = LineChartView()
    var lineChartDataSet: LineChartDataSet!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    func configureCell() {
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 13
    }
    
    func setGraph(type: ShowingData) {
        lineChartView.isUserInteractionEnabled = false
        lineChartView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: 400)
        lineChartView.center = contentView.center
        lineChartView.delegate = self
        contentView.addSubview(lineChartView)
        
        // 데이터 설정
        let dataEntries = generateLineChartDataEntries()
        lineChartDataSet = LineChartDataSet(entries: dataEntries, label: type.rawValue)
        
        // 데이터 스타일 설정
        lineChartDataSet.colors = [.primaryColor]  // 선 색상
        lineChartDataSet.circleColors = [.primaryColor]  // 데이터 포인트 색상
        lineChartDataSet.circleRadius = 2.0  // 데이터 포인트 크기
        lineChartDataSet.lineWidth = 2.0  // 선 굵기
        lineChartDataSet.valueColors = [.black]  // 데이터 값 색상
        
        // LineChartData 설정
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        // 기타 차트 설정 (옵션)
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.dragDecelerationEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.rightAxis.enabled = false
        // x축 격자무늬 없애기
        lineChartView.xAxis.drawGridLinesEnabled = false
        // 왼쪽 y축 격자무늬 없애기
        lineChartView.leftAxis.drawGridLinesEnabled = false
        // 오른쪽 y축 격자무늬 없애기
        lineChartView.rightAxis.drawGridLinesEnabled = false
    }
    
    func generateLineChartDataEntries() -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []
        
        let values = (0...5).map{ _ in Int.random(in: 10...300) }  // 예시 데이터
        for (index, value) in values.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: Double(value))
            dataEntries.append(dataEntry)
        }
        
        return dataEntries
    }
}

extension GraphCollectionViewCell: ChartViewDelegate {
    
    // ChartViewDelegate 메소드 구현
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Selected entry: \(entry)")
        // 여기서 특정 데이터 포인트를 선택했을 때의 동작을 정의할 수 있습니다.
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("Deselected entry")
        // 포인트 외부를 터치했을 때의 동작을 정의할 수 있습니다.
    }
}
