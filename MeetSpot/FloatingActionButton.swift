import UIKit

@IBDesignable
open class FloatingActionButton: UIButton {
  private struct Constants {
    static let size: CGFloat = 56
    
    static let backgroundColor: UIColor = .systemBlue
    static let tintColor: UIColor = .white
    
    static let borderColor: CGColor = UIColor.gray.cgColor
    static let borderWidth: CGFloat = 0.3
    
    static let shadowColor: CGColor = UIColor.black.cgColor
    static let shadowOffset: CGSize = CGSize(width: 2, height: 2)
    static let shadowRadius: CGFloat = 2
    static let shadowOpacity: Float = 0.4
  }
  
  /// ボタンの一辺の長さ
  @IBInspectable
  open var size: CGFloat = Constants.size {
    didSet {
      layer.cornerRadius = size / 2
      
      // Viewの再描画
      self.setNeedsDisplay()
    }
  }
  
  /// 影を表現する`CAShapeLayer`
  private let shadowLayer: CAShapeLayer = CAShapeLayer()
  
  /// 最小描画サイズ
  @IBInspectable
  public override var intrinsicContentSize: CGSize {
    let size: CGSize = CGSize(width: Constants.size, height: Constants.size)
    return size
  }
  
  // MARK: - Initializer
  public init(systemName: String, state: UIControl.State) {
    super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
    
    guard let image: UIImage = UIImage(systemName: systemName) else { return }
    self.setImage(image, for: state)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    size = min(frame.size.height, frame.size.width)
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    size = min(frame.size.height, frame.size.width)
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
    configureIcon()
    configureShadow()
    configureRasterization()
  }
  
  /// アイコンを設定する
  private func configureIcon() {
    backgroundColor = Constants.backgroundColor
    tintColor = Constants.tintColor
    
    layer.cornerRadius = size / 2
    
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
  
  /// ラスタライズを設定する
  private func configureRasterization() {
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }
}
