import UIKit

extension UIImage {
    func toSquare() -> UIImage? {
        let originalWidth  = self.size.width
        let originalHeight = self.size.height
        let squareSize = min(originalWidth, originalWidth)

        // 정사각형으로 자를 CGRect 계산
        let xOffset = (originalWidth - squareSize) / 2
        let yOffset = (originalHeight - squareSize) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: squareSize, height: squareSize)

        // CGImage로 자르고, UIImage로 변환
        guard let croppedCgImage = self.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        return UIImage(cgImage: croppedCgImage)
    }
}
