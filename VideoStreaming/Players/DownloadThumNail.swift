import AVKit
import Foundation

typealias image = (_ image: UIImage) -> Void

protocol ThumbNailProtocol {
    func downloadThumbNail(url: URL, completionHandler: @escaping image)
}

extension URL: ThumbNailProtocol {
    func downloadThumbNail(url: URL, completionHandler: @escaping image) {}
}

class DownloadThumbNail: ThumbNailProtocol {
    func downloadThumbNail(url: URL, completionHandler: @escaping image) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImgGenerate: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 2)
            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            if img != nil {
                let frameImg = UIImage(cgImage: img!)
                DispatchQueue.main.async {
                    completionHandler(frameImg)
                }
            }
        }
    }
}
