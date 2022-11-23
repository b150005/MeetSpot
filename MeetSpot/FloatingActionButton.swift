import UIKit

@IBDesignable
open class FloatingActionButton: UIButton {
  var roundSize: CGSize = CGSize(width: 56, height: 56) {
    didSet {
      frame.size = roundSize
    }
  }
  var labelSize: CGSize = CGSize(width: 120, height: 30) {
    didSet {
      frame.size = labelSize
    }
  }
  var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
  
  /// 最小描画サイズ
  @IBInspectable
  public override var intrinsicContentSize: CGSize {
    var size: CGSize = CGSize(width: frame.size.width, height: frame.size.height)
    
    // 文字列を含む場合はpaddingを付与
    if let _ = currentTitle {
      size.width += padding.left + padding.right
      size.height += padding.top + padding.bottom
    }
    
    return size
  }
  
  /// `UIImage`をもつボタンを生成する
  /// - Parameters:
  ///   - image: 表示する`UIImage`
  ///   - tintColor: `image`の色
  ///   - backgroundColor: 背景色
  init(image: UIImage?, tintColor: UIColor = .white, backgroundColor: UIColor = .systemBlue) {
    super.init(frame: CGRect(origin: .zero, size: roundSize))
    
    setImage(image, for: .normal)
    self.tintColor = tintColor
    self.layer.backgroundColor = backgroundColor.cgColor
  }
  
  /// `UILabel`をもつボタンを生成する
  /// - Parameters:
  ///   - title: 表示する文字列
  ///   - titleColor: `title`の色
  ///   - backgroundColor: 背景色
  init(title: String, titleColor: UIColor = .systemBlue, backgroundColor: UIColor = .white) {
    super.init(frame: CGRect(origin: .zero, size: labelSize))
    
    setTitle(title, for: .normal)
    setTitleColor(titleColor, for: .normal)
    self.layer.backgroundColor = backgroundColor.cgColor
    
    // ボタンの横幅に応じてフォントサイズを自動調整
    titleLabel?.adjustsFontSizeToFitWidth = true
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public required init?(coder: NSCoder) {
    fatalError()
  }
  
  // MARK: - Layout
  open override func draw(_ rect: CGRect) {
    super.draw(rect)
    configureLayer()
  }
}

extension FloatingActionButton {
  /// レイヤーを設定する
  private func configureLayer() {
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    layer.cornerRadius = bounds.midY
    
    layer.borderColor = UIColor.gray.cgColor
    layer.borderWidth = 0.3
    
    layer.shadowOpacity = 0.4
    layer.shadowOffset = .zero
  }
}
