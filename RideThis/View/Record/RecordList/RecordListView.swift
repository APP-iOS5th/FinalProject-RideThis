import UIKit
import SnapKit
import Combine

class RecordListView: RideThisViewController, UIScrollViewDelegate {
    weak var coordinator: RecordListCoordinator?
    
    private let viewModel = RecordListViewModel()
    
    private var scrollView: UIScrollView!
    private var contentView: UIStackView!
    private var loadedMonths = 0
    private let monthsToLoadPerBatch = 3
    
    private let firebaseService = FireBaseService()
    private var cancellables = Set<AnyCancellable>()
    
    private let noRecordLabel: RideThisLabel = {
        let label = RideThisLabel(fontType: .defaultSize, fontColor: .gray, text: "저장된 기록이 없습니다.")
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "라이딩 목록"
        
        setupScrollView()
        setupContentView()
        setupNoRecordLabel()
        
        viewModel.$records
            .combineLatest(viewModel.$months)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (records, months) in
                self?.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                self?.loadedMonths = 0
                self?.updateUI(records: records, months: months)
            }
            .store(in: &cancellables)
        
        viewModel.fetchRecordsFromFirebase()
    }
    
    private func setupNoRecordLabel() {
        view.addSubview(noRecordLabel)
        noRecordLabel.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
        }
    }
    
    private func updateUI(records: [String: [RecordModel]], months: [String]) {
        if records.isEmpty {
            noRecordLabel.isHidden = false
            scrollView.isHidden = true
        } else {
            noRecordLabel.isHidden = true
            scrollView.isHidden = false
            loadMoreMonths()
        }
    }
    
    private func loadMoreMonths() {
        let endIndex = min(loadedMonths + monthsToLoadPerBatch, viewModel.months.count)
        for i in loadedMonths..<endIndex {
            let month = viewModel.months[i]
            let monthView = createMonthView(for: month, with: viewModel.getRecordsForMonth(month))
            contentView.addArrangedSubview(monthView)
        }
        loadedMonths = endIndex
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { scrollView in
            scrollView.edges.equalToSuperview()
        }
        
        // iOS 16.6 이하 버전에서 스크롤 뷰가 부모 뷰의 스크롤을 방해하지 않도록 설정
        if #available(iOS 17.4, *) {
            scrollView.transfersVerticalScrollingToParent = false
        } else {
            scrollView.alwaysBounceVertical = false
        }
    }
    
    private func setupContentView() {
        contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 20
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }
    
    private func createMonthView(for month: String, with records: [RecordModel]) -> UIView {
        let monthView = MonthView()
        monthView.configure(month: month, records: records)
        monthView.onRecordSelected = { [weak self] record in
            self?.showRecordDetail(record: record)
        }
        return monthView
    }
    
    private func showRecordDetail(record: RecordModel) {
        coordinator?.moveToRecordDetailView(with: record)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - scrollViewHeight - 100 {
            if loadedMonths < viewModel.months.count {
                loadMoreMonths()
            }
        }
    }
}
