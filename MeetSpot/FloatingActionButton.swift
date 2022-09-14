import UIKit

@IBDesignable
open class FloatingActionButton: UIButton {
  private struct Constants {
    static let size: CGFloat = 56
    
    static let padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    static let backgroundColor: UIColor = .systemBlue
    static let tintColor: UIColor = .white
    
    static let borderColor: CGColor = UIColor.gray.cgColor
    static let borderWidth: CGFloat = 0.3
    
    static let shadowColor: CGColor = UIColor.black.cgColor
    static let shadowOffset: CGSize = CGSize(width: 2, height: 2)
    static let shadowRadius: CGFloat = 2
    static let shadowOpacity: Float = 0.4
  }
  
  /// 影を表現する`CAShapeLayer`
  private let shadowLayer: CAShapeLayer = CAShapeLayer()
  
  /// 最小描画サイズ
  @IBInspectable
  public override var intrinsicContentSize: CGSize {
    var size: CGSize = CGSize(width: frame.size.width, height: frame.size.height)
    
    // 文字列を含む場合はpaddingを付与
    if let _ = currentTitle {
      size.width += Constants.padding.left + Constants.padding.right
      size.height += Constants.padding.top + Constants.padding.bottom
    }
    
    return size
  }
  
  /// 背景色
  /// `UIView#draw(_:)`でボタンに設定される
  @IBInspectable
  private let defaultBackgroundColor: UIColor?
  
  /// コンテンツの色
  /// `UIView#draw(_:)`でボタンに設定される
  @IBInspectable
  private let defaultTintColor: UIColor?
  
  // MARK: - Initializer
  /// 1つの`UIImage`をもつボタンを生成する
  public init(width: CGFloat = 56, height: CGFloat = 56,
              systemName: String, backgroundColor: UIColor = .red, tintColor: UIColor = .white,
              state: UIControl.State = .normal) {
    defaultBackgroundColor = backgroundColor
    defaultTintColor = tintColor
    
    super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let image: UIImage = UIImage(systemName: systemName) else { return }
    setImage(image, for: state)
  }
  
  /// 1つの`UILabel`をもつボタンを生成する
  public init(width: CGFloat = 100, height: CGFloat = 30,
              title: String, titleColor: UIColor = .white,
              backgroundColor: UIColor = .red, tintColor: UIColor = .systemBlue,
              state: UIControl.State = .normal) {
    defaultBackgroundColor = backgroundColor
    defaultTintColor = tintColor
    
    super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
    
    setTitle(title, for: state)
    setTitleColor(titleColor, for: state)
  }
  
  public override init(frame: CGRect) {
    defaultBackgroundColor = .systemBlue
    defaultTintColor = .white
    
    super.init(frame: frame)
  }
  
  public required init?(coder: NSCoder) {
    defaultBackgroundColor = .systemBlue
    defaultTintColor = .white
    
    super.init(coder: coder)
  }
  
  // MARK: - Layout
  open override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    configureWithDraw()
  }
}

extension FloatingActionButton {
  /// `UIView#draw(_:)`メソッドで呼び出す設定処理
  private func configureWithDraw() {
    configureColor()
    configureLayer()
    configureShadow()
  }
  
  /// 色を設定する
  private func configureColor() {
    backgroundColor = defaultBackgroundColor
    tintColor = defaultTintColor
  }
  
  /// レイヤーを設定する
  private func configureLayer() {
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    let minLength: CGFloat = min(frame.size.width, frame.size.height)
    layer.cornerRadius = minLength / 2
    
    layer.borderColor = Constants.borderColor
    layer.borderWidth = Constants.borderWidth
  }
  
  /// 影を設定する
  private func configureShadow() {
    shadowLayer.removeFromSuperlayer()
    
    shadowLayer.cornerRadius = layer.cornerRadius
    
    shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    
    shadowLayer.fillColor = backgroundColor?.cgColor
    shadowLayer.backgroundColor = UIColor.black.cgColor
    
    shadowLayer.shadowPath = shadowLayer.path
    shadowLayer.shadowColor = Constants.shadowColor
    shadowLayer.shadowOffset = Constants.shadowOffset
    shadowLayer.shadowRadius = Constants.shadowRadius
    shadowLayer.shadowOpacity = Constants.shadowOpacity
    
    layer.insertSublayer(shadowLayer, at: 0)
  }
}
