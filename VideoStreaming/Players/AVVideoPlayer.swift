import AVKit

protocol AVvideoPlayerProtocol: class {
    func seekBarValue(min: Float, max: Float, value: Float)
    func sessionEnd()
    func thumbNailImage(thumb: UIImage)
    func isPlaying()
}

class AVvideoPlayer: NSObject {
    deinit {
        print("VideoPlayer deallocated")
        observer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private var myImage: UIImage?
    private var avPlayer: AVPlayer?
    private var avPlayerLayer: AVPlayerLayer?
    private var playerItemContext = 0
    var observer: NSKeyValueObservation?
    
    weak var delegate: AVvideoPlayerProtocol?
    
    init?(url: String? = nil, playerView: UIView?, delegate: AVvideoPlayerProtocol? = nil) {
        super.init()
        self.delegate = delegate
        guard let playerView = playerView, let playerUrl = url else { return nil}
        playVideo(url: playerUrl, playerView: playerView)
    }
    
    func playVideo(url: String, playerView: UIView) {
        let videoURL = URL(string: url)
        let asset = AVAsset(url: videoURL!)
        let assetKeys = ["playable", "hasProtectedContent"]
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.frame = playerView.bounds
        avPlayerLayer?.videoGravity = .resizeAspectFill
        playerView.layer.addSublayer(avPlayerLayer!)
        playerView.backgroundColor = .black
        addObserversToPlayer(playerItem: playerItem)
    }
    
    var isPlaying: Bool {
        if avPlayer?.rate == 0.0 {
            return false
        }
        return true
    }
    
    func resizeFill(playerView: UIView) {
        guard let player = avPlayerLayer else { return }
        player.frame = playerView.layer.bounds
        player.videoGravity = .resizeAspectFill
        playerView.layer.masksToBounds = true
    }
    
    func startStreaming() {
        guard let player = avPlayer else { return }
        player.play()
    }
    
    func stopStreaming() {
        guard let player = avPlayer else { return }
        player.pause()
        avPlayer = nil
        avPlayerLayer = nil
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
    
    func seekTime(value: Float, duration: Float) {
        guard let player = avPlayer, isPlaying == true else { return }
        player.seek(to: CMTimeMakeWithSeconds(Float64(value), preferredTimescale: Int32(duration)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
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
            let value = CMTimeGetSeconds(currentItem.currentTime());
            self?.delegate?.seekBarValue(min: Float(minTime), max: Float(duration), value: Float(value))
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func downloadThumNails(url: URL) {
        url.downloadThumbNail(url: url, completionHandler: { [weak self] thumbNail in
            self?.delegate?.thumbNailImage(thumb: thumbNail)
        })
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        delegate?.sessionEnd()
    }
}
