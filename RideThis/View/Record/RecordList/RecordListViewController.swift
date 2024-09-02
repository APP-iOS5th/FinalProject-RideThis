import UIKit
import SnapKit
import Combine

class RecordListViewController: RideThisViewController, UIScrollViewDelegate {
    weak var coordinator: RecordListCoordinator?
    
    private let viewModel = RecordListViewModel()
    
    private var scrollView: UIScrollView!
    private var contentView: UIStackView!
    private var loadedMonths = 0
    private let monthsToLoadPerBatch = 3
    
    private let firebaseService = FireBaseService()
    private var cancellables = Set<AnyCancellable>()
    
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
        scrollView.transfersVerticalScrollingToParent = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { scrol in
            scrol.edges.equalToSuperview()
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
        for i in loadedMonths..<endIndex {
            let month = viewModel.months[i]
            let monthView = createMonthView(for: month, with: viewModel.getRecordsForMonth(month))
            contentView.addArrangedSubview(monthView)
        }
        loadedMonths = endIndex
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
