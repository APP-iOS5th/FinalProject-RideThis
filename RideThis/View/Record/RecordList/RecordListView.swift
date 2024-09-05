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
    
    private let noRecordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "저장된 기록이 없습니다."
//        label.textColor = .primaryColor
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "기록 목록"
        
        setupScrollView()
        setupContentView()
        
        viewModel.$records
            .combineLatest(viewModel.$months)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_, _) in
                self?.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                self?.loadedMonths = 0
                self?.loadMoreMonths()
            }
            .store(in: &cancellables)
        
        viewModel.fetchRecordsFromFirebase()
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
    
    private func loadMoreMonths() {
        let endIndex = min(loadedMonths + monthsToLoadPerBatch, viewModel.months.count)
        if endIndex > 0 {
            noRecordLabel.removeFromSuperview()
            for i in loadedMonths..<endIndex {
                let month = viewModel.months[i]
                let monthView = createMonthView(for: month, with: viewModel.getRecordsForMonth(month))
                contentView.addArrangedSubview(monthView)
            }
            loadedMonths = endIndex
        } else {
            self.view.addSubview(noRecordLabel)
            
            noRecordLabel.snp.makeConstraints {
                $0.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
                $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
            }
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
