import Foundation
import UIKit
import SnapKit
import Combine

class AlarmView: RideThisViewController {
    
    private let viewModel = AlarmViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    private lazy var alarmTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(AlarmTableViewCell.self, forCellReuseIdentifier: "AlarmTableViewCell")
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setCombineData()
    }
    
    func configureUI() {
        setTableView()
    }
    
    func setTableView() {
        view.addSubview(alarmTableView)
        
        alarmTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setCombineData() {
        viewModel.$alarams
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alarm in
                guard let self = self else { return }
                
                print(alarm)
            }
            .store(in: &cancellable)
    }
}

extension AlarmView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmTableViewCell", for: indexPath) as? AlarmTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}
