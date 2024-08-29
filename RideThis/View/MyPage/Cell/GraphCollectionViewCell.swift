import UIKit
import DGCharts

class GraphCollectionViewCell: UICollectionViewCell {
    let scrollView = UIScrollView()
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
    
    func setGraph(type: ShowingData, records: [RecordModel], periodCase: RecordPeriodCase) {
        // MARK: 1안 - width를 넓혀서 여기를 스크롤뷰로 해보기
        // MARK: 2안 - 3개월 넘었을 때는 평균값으로 표시
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.isUserInteractionEnabled = true
        lineChartView.delegate = self
        scrollView.subviews.forEach{ $0.removeFromSuperview() }
        contentView.subviews.forEach{ $0.removeFromSuperview() }
        if periodCase == .threeMonths || periodCase == .sixMonths {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(scrollView)
            scrollView.addSubview(lineChartView)
            
            scrollView.snp.makeConstraints {
                $0.top.equalTo(contentView.snp.top)
                $0.right.equalTo(contentView.snp.right)
                $0.left.equalTo(contentView.snp.left)
                $0.bottom.equalTo(contentView.snp.bottom)
            }
            
            let widthConstraint: CGFloat = periodCase == .threeMonths ? 4 : 6
            lineChartView.snp.makeConstraints {
                $0.top.equalTo(scrollView.snp.top)
                $0.right.equalTo(scrollView.snp.right)
                $0.left.equalTo(scrollView.snp.left)
                $0.bottom.equalTo(scrollView.snp.bottom)
                $0.width.equalTo(contentView.frame.size.width * widthConstraint)
                $0.height.equalTo(400)
            }
        } else {
            lineChartView.center = contentView.center
            
            contentView.addSubview(lineChartView)
            lineChartView.snp.makeConstraints {
                $0.top.equalTo(contentView.snp.top)
                $0.left.equalTo(contentView.snp.left)
                $0.right.equalTo(contentView.snp.right)
                $0.bottom.equalTo(contentView.snp.bottom)
                $0.height.equalTo(400)
            }
        }
        
        // 데이터 설정
        let dataEntries = generateLineChartDataEntries(type: type, records: records, periodCase: periodCase)
        lineChartDataSet = LineChartDataSet(entries: dataEntries, label: type.rawValue)
        
        // 데이터 스타일 설정
        lineChartDataSet.colors = [.primaryColor]  // 선 색상
        lineChartDataSet.circleColors = [.primaryColor]  // 데이터 포인트 색상
        lineChartDataSet.circleRadius = 2.0  // 데이터 포인트 크기
        lineChartDataSet.lineWidth = 1.5  // 선 굵기
        lineChartDataSet.valueColors = [.black]  // 데이터 값 색상
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.cubicIntensity = 0.2
        
        // LineChartData 설정
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
        
        // 기타 차트 설정 (옵션)
        lineChartView.highlightPerDragEnabled = false
        lineChartView.highlightPerTapEnabled = false
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
    
    func generateLineChartDataEntries(type: ShowingData, records: [RecordModel], periodCase: RecordPeriodCase) -> [ChartDataEntry] {
        var dataEntries: [ChartDataEntry] = []
        let today = Date()
        let calendar = Calendar.current
        
        var lastDateKeys: [String] = []
        for i in 0..<periodCase.graphXAxis.count {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateString = formatDate(date: date)
                lastDateKeys.append(dateString)
            }
        }
        lastDateKeys.reverse()
        
        let filteredData = records
            .filter { $0.record_data! >= periodCase.periodCondition && $0.record_data! <= today }
            .sorted(by: { $0.record_data! < $1.record_data! })
        
        let groupedData = Dictionary(grouping: filteredData) { (record: RecordModel) -> String in
            return formatDate(date: record.record_start_time!)
        }
        
        var result: [String: Double] = [:]
        lastDateKeys.forEach { dateString in
            result[dateString] = 0.0
        }
        
        for (dateString, records) in groupedData {
            let totalValue = records.reduce(0) {
                switch type {
                case .cadence:
                    return $0 + $1.record_cadence
                case .distance:
                    return $0 + $1.record_distance
                case .speed:
                    return $0 + $1.record_speed
                case .calories:
                    return $0 + $1.record_calories
                }
            }
            result[dateString] = totalValue.getTwoDecimal
        }

        let sortedResult = result.sorted { $0.key < $1.key }
        
        for (index, value) in sortedResult.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: value.value)
            dataEntries.append(dataEntry)
        }
        
        // MARK: 3개월 부터는 월 평균으로 보여준다?
        let dataSet = LineChartDataSet(entries: dataEntries, label: "My Data")
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        if periodCase == .threeMonths || periodCase == .sixMonths {
            lineChartView.xAxis.granularity = 3
        } else {
            lineChartView.xAxis.granularity = 1
        }
        
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: periodCase.graphXAxis)
        
        return dataEntries
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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
