import UIKit
import SnapKit

class SearchUserView: RideThisViewController {
    // MARK: UIComponents
    // MARK: Search Bar
    private let searchController = UISearchController()
    // MARK: User Search Result Table
    private lazy var searchUserTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(FollowTableViewCell.self, forCellReuseIdentifier: "SearchUserTableCell")
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 13
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        setNavigationComponents()
        setSearchBar()
        setSearchUserTable()
    }
    
    func setNavigationComponents() {
        self.title = "팔로잉 추가"
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.sheetPresentationController?.prefersGrabberVisible = true
    }
    
    func setSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "이메일 또는 닉네임을 검색해주세요."
        searchController.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func setSearchUserTable() {
        view.addSubview(searchUserTable)
        
        searchUserTable.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.left.equalTo(view.snp.left).offset(15)
            $0.right.equalTo(view.snp.right).offset(-15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    @objc func cancelAction() {
        dismiss(animated: true)
    }
}

extension SearchUserView: UISearchBarDelegate {
    // MARK: TODO - 키보드에서 입력할 때 event
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension SearchUserView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUserTableCell", for: indexPath) as? FollowTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}