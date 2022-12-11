import UIKit

class CardTableViewCell: UITableViewCell {
  override var contentView: UIView {
    get {
      return self.contentView
    }
    set {
      newValue.layer.borderWidth = 0.1
      newValue.layer.cornerRadius = 5
      newValue.backgroundColor = .white
    }
  }
  
  override var layer: CALayer {
    get {
      return self.layer
    }
    set {
      newValue.masksToBounds = false
      newValue.shadowColor = UIColor.gray.cgColor
      newValue.shadowRadius = 2
      newValue.shadowOpacity = 0.15
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
