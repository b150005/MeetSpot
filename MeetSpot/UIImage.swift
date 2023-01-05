import UIKit

extension UIImage {
  func scalePreservingAspectRatio(targetSize: CGSize = CGSize(width: 20, height: 20)) -> UIImage {
    let scaleFactor: CGFloat = min(targetSize.width / size.width, targetSize.height / size.height)
    
    let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
    return UIGraphicsImageRenderer(size: scaledImageSize).image { _ in
      self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
    }
  }
}
