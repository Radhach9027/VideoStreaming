import AVKit

protocol AVvideoPlayerProtocol: class {
    func seekBarValue(min: Float, max: Float, value: Float)
    func sessionEnd()
    func thumbNailImage(thumb: UIImage)
    func isPlaying()
}

enum Gravity {
    case resize
    case fill
    case aspectFit
    
    fileprivate func getGravity(gravity: Gravity) -> AVLayerVideoGravity {
        switch gravity {
        case .resize:
            return .resize
        case .fill:
            return .resizeAspectFill
        case .aspectFit:
            return .resizeAspect
        }
    }
}

final class AVvideoPlayer: NSObject {
    deinit {
        print("VideoPlayer deallocated")
        observer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private var myImage: UIImage?
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var playerItemContext = 0
    private var observer: NSKeyValueObservation?
    weak var delegate: AVvideoPlayerProtocol?
    
    init?(url: String? = nil, playerView: UIView?, delegate: AVvideoPlayerProtocol? = nil) {
        super.init()
        self.delegate = delegate
        guard let playerView = playerView, let playerUrl = url else { return nil }
        playVideo(url: playerUrl, playerView: playerView)
    }
}

extension AVvideoPlayer {
    var isPlaying: Bool {
        if avPlayer?.rate == 0.0 {
            return false
        }
        return true
    }
    
    func resizeFill(playerView: UIView, gravity: Gravity) {
        guard let player = avPlayerLayer else { return }
        player.frame = playerView.layer.bounds
        playerView.layer.masksToBounds = true
        player.videoGravity = gravity.getGravity(gravity: gravity)
    }
    
    func startStreaming() {
        guard let player = avPlayer else { return }
        player.play()
    }
    
    func stopStreaming() {
        guard let player = avPlayer else { return }
        player.pause()
        removePlayerLayer()
        avPlayer = nil
        avPlayerLayer = nil
    }
    
    func removePlayerLayer() {
        guard let playerLayer = avPlayerLayer else { return }
        DispatchQueue.main.async {
            playerLayer.removeFromSuperlayer()
        }
    }
    
    func pauseStreaming() {
        if let player = avPlayer {
            player.pause()
        }
    }
    
    func replayStreaming() {
        guard let player = avPlayer else { return }
        player.seek(to: .zero)
        player.play()
    }
    
    func playSelected(url: String, playerView: UIView) {
        stopStreaming()
        playVideo(url: url, playerView: playerView)
        startStreaming()
    }
    
    func seekTime(value: Float, duration: Float) {
        guard let player = avPlayer, isPlaying == true else { return }
        player.seek(to: CMTimeMakeWithSeconds(Float64(value), preferredTimescale: Int32(duration)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

extension AVvideoPlayer {
    private func playVideo(url: String, playerView: UIView) {
        let videoURL = URL(string: url)
        let asset = AVAsset(url: videoURL!)
        let assetKeys = ["playable", "hasProtectedContent"]
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = .resize
        playerView.layer.addSublayer(avPlayerLayer!)
        avPlayerLayer?.frame = playerView.bounds
        playerView.backgroundColor = .black
        addObserversToPlayer(playerItem: playerItem)
    }
    
    private func addObserversToPlayer(playerItem: AVPlayerItem) {
        guard let player = avPlayer else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] _ in
            guard let currentItem = player.currentItem else {
                return
            }
            if player.rate == 1 {
                self?.delegate?.isPlaying()
            }
            let minTime = CMTimeGetSeconds(currentItem.currentTime())
            let duration = CMTimeGetSeconds(currentItem.duration)
            self?.delegate?.seekBarValue(min: Float(minTime), max: Float(duration), value: Float(minTime))
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func downloadThumNails(url: URL) {
        url.downloadThumbNail(url: url, completionHandler: { [weak self] thumbNail in
            self?.delegate?.thumbNailImage(thumb: thumbNail)
        })
    }
    
    @objc private func playerDidFinishPlaying(sender: Notification) {
        delegate?.sessionEnd()
    }
}
