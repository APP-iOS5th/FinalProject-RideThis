import UIKit

class GraphCollectionViewCell: UICollectionViewCell {
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
}
