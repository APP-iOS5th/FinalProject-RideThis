import UIKit
import SnapKit

class FollowManageView: RideThisViewController {
    
    // MARK: UIComponents
    // MARK: Search Bar
    private let searchController = UISearchController()
    // MARK: Following / Follower Picker
    private let followOption: [String] = ["팔로워", "팔로잉"]
    private lazy var followPicker: UISegmentedControl = {
        let picker = UISegmentedControl(items: self.followOption)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.selectedSegmentIndex = 0
        picker.addTarget(self, action: #selector(optionChanged(_:)), for: .valueChanged)
        
        return picker
    }()
    // MARK: Follow Table
    private let followContainer = RideThisContainer()
    private lazy var followTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(FollowTableViewCell.self, forCellReuseIdentifier: "FollowTableViewCell")
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        setNavigationComponents()
        setSearchBar()
        setFollowPicker()
        setFollowTable()
    }
    
    func setNavigationComponents() {
        self.title = "매드카우"
    }
    
    func setSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "이메일 또는 닉네임을 검색해주세요."
        searchController.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func setFollowPicker() {
        view.addSubview(followPicker)
        
        followPicker.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(view.snp.left).offset(15)
            $0.right.equalTo(view.snp.right).offset(-15)
        }
    }
    
    func setFollowTable() {
        view.addSubview(followContainer)
        
        followContainer.snp.makeConstraints {
            $0.top.equalTo(followPicker.snp.bottom).offset(15)
            $0.left.equalTo(followPicker.snp.left)
            $0.right.equalTo(followPicker.snp.right)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        followContainer.addSubview(followTable)
        
        followTable.snp.makeConstraints {
            $0.top.equalTo(followContainer.snp.top).offset(5)
            $0.left.equalTo(followContainer.snp.left).offset(5)
            $0.right.equalTo(followContainer.snp.right).offset(-5)
            $0.bottom.equalTo(followContainer.snp.bottom).offset(-5)
        }
    }
    
    @objc func optionChanged(_ sender: UISegmentedControl) {
        
    }
}

extension FollowManageView: UISearchBarDelegate {
    // MARK: TODO - 키보드에서 입력할 때 event
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension FollowManageView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as? FollowTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
