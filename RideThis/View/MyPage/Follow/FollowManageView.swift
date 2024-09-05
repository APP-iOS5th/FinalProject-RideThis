import UIKit
import SnapKit
import Combine

class FollowManageView: RideThisViewController {
    
    // MARK: Data Components
    var user: User?
    let followViewModel: FollowManageViewModel
    var followCoordinator: FollowManageCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    init(user: User?, followViewModel: FollowManageViewModel) {
        self.user = user
        self.followViewModel = followViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        setCombineData()
    }
    
    func configureUI() {
        setNavigationComponents()
        setSearchBar()
        setFollowPicker()
        setFollowTable()
    }
    
    func setNavigationComponents() {
        self.title = ""
        let searchButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(searchUserButton))
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func setSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "이메일 또는 닉네임을 검색해주세요."
        searchController.searchBar.autocapitalizationType = .none
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
    
    func setCombineData() {
        followViewModel.$followDatas
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.followTable.reloadData()
                }
            }
            .store(in: &cancellable)
        
        Task {
            await followViewModel.fetchFollowData(user: user!, type: .follower)
        }
    }
    
    @objc func optionChanged(_ sender: UISegmentedControl) {
        let followType: FollowType = self.followPicker.selectedSegmentIndex == 0 ? .follower : .following
        followViewModel.changeSegmentValue(user: user!, type: followType)
    }
    
    @objc func searchUserButton() {
        let searchUserView = UINavigationController(rootViewController: SearchUserView())
        present(searchUserView, animated: true)
    }
}

extension FollowManageView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        followViewModel.searchUser(text: searchText, user: self.user!, type: self.followPicker.selectedSegmentIndex == 0 ? .follower : .following)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension FollowManageView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followViewModel.followDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as? FollowTableViewCell else {
            return UITableViewCell()
        }
        
        let followUser = followViewModel.followDatas[indexPath.row]
        cell.cellUser = followUser
        cell.signedUser = user
        
        cell.configureUserInfo(viewType: .followView, followType: self.followPicker.selectedSegmentIndex == 0 ? .follower : .following)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: TODO - 선택한 유저의 프로필 보여주기
        let selectedUser = self.followViewModel.followDatas[indexPath.row]
        let profileCoordinator = UserProfileCoordinator(navigationController: self.navigationController!, selectedUser: selectedUser)
        profileCoordinator.start()
    }
}

extension FollowManageView: UpdateUserDelegate {
    func updateUser(user: User) {
        self.user = user
        Task {
            await followViewModel.fetchFollowData(user: user, type: self.followPicker.selectedSegmentIndex == 0 ? .follower : .following)
        }
    }
}
