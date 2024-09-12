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
    
    // MARK: TODO - 평균값 수평선으로 그래프로 보여주기
    // MARK: TODO - 3개월 부터는 주차별로 좀 더 간소하게 보여줄 수 있으면 진행
    func setGraph(type: RecordDataCase, records: [RecordModel], period: RecordPeriodCase) {
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.removeFromSuperview()
        lineChartView.removeFromSuperview()

        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.isUserInteractionEnabled = true
        lineChartView.legend.enabled = false
        lineChartView.delegate = self
        lineChartView.extraBottomOffset = 20.0

        switch period {
        case .oneWeek:
            contentView.addSubview(lineChartView)
            lineChartView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(400)
            }
        case .oneMonth, .threeMonths, .sixMonths:
            let widthMultiplier: CGFloat = period == .oneMonth ? 2 : period == .threeMonths ? 4 : 8
            
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(scrollView)
            scrollView.addSubview(lineChartView)

            scrollView.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }

            lineChartView.snp.remakeConstraints {
                $0.edges.equalTo(scrollView.contentLayoutGuide)
                $0.height.equalTo(400)
                $0.width.equalTo(contentView.snp.width).multipliedBy(widthMultiplier)
            }

            scrollView.contentLayoutGuide.snp.makeConstraints {
                $0.width.equalTo(lineChartView)
                $0.height.equalTo(scrollView.frameLayoutGuide)
            }
        }
        
        // 데이터 설정
        let dataEntries = generateLineChartDataEntries(type: type, records: records, periodCase: period)
//        lineChartDataSet = LineChartDataSet(entries: dataEntries, label: type.rawValue)
        lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "")
        
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
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
    }
    
    // MARK: TODO - 데이터 관련 로직들 ViewModel에서 처리하도록 수정
    func generateLineChartDataEntries(type: RecordDataCase, records: [RecordModel], periodCase: RecordPeriodCase) -> [ChartDataEntry] {
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
        
        let dataSet = LineChartDataSet(entries: dataEntries, label: "")
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        switch periodCase {
        case .oneWeek:
            lineChartView.xAxis.granularity = 1
        default:
            lineChartView.xAxis.granularity = 3
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

// MARK: 나중에 그래프 데이터를 선택했을 때 작은 말풍선에 보여준다던가 하는거 할 수도?
extension GraphCollectionViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Selected entry: \(entry)")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("Deselected entry")
    }
}
