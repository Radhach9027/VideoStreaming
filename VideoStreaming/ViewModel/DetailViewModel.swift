import UIKit

protocol DetailViewModelProtocol { // can be used for mocking & testing
    func playSelectedVideo(model: ThumbNailModel, playerView: UIView)
    func play()
    func pause()
    func stop()
    func replay()
    func playerStates(state: UIButton) -> PlayerStates
    func playerThumbNailSelection(state: UIButton) -> Selection
    func seekPlayerPosition(value: Float)
    func resizeFill(playerView: UIView)
}

enum PlayerStates {
    case play
    case pause
    case replay
    case stop
}

enum Selection {
    case selected
    case notSelected
}

class DetailViewModel: DetailViewModelProtocol {
    private var player: AVvideoPlayer?
    private var model: ThumbNailModel?
    internal weak var delegate: DetailViewModelDelegate?

    init?(model: ThumbNailModel?, playerView: UIView?, delegate: DetailViewModelDelegate?) {
        guard let model = model, let playerView = playerView, let delegate = delegate else { return nil }
        self.delegate = delegate
        self.model = model
        self.player = AVvideoPlayer(url: model.url, playerView: playerView, delegate: self)
    }

    func playSelectedVideo(model: ThumbNailModel, playerView: UIView) {
        player?.stopStreaming()
        player?.playVideo(url: model.url, playerView: playerView)
        player?.startStreaming()
    }
    
    func play() {
        player?.startStreaming()
    }
    
    func pause() {
        player?.pauseStreaming()
    }
    
    func stop() {
        player?.stopStreaming()
        player = nil
    }
    
    func replay() {
        player?.replayStreaming()
    }

    func playerStates(state: UIButton) -> PlayerStates {
        if (state.imageView?.image?.isEqualToImage(UIImage(named: SystemImages.playFull.rawValue)))! {
            return .play
        } else if (state.imageView?.image?.isEqualToImage(UIImage(named: SystemImages.pause.rawValue)))! {
            return .pause
        } else if (state.imageView?.image?.isEqualToImage(UIImage(named: SystemImages.replay.rawValue)))! {
            return .replay
        }
        return .stop
    }

    func playerThumbNailSelection(state: UIButton) -> Selection {
        if (state.imageView?.image?.isEqualToImage(UIImage(named: SystemImages.thumbNail.rawValue)))! {
            return .selected
        } else {
            return .notSelected
        }
    }
    
    func playerResized(state: UIButton)-> Selection {
        if (state.imageView?.image?.isEqualToImage(UIImage(named: SystemImages.maximize.rawValue)))! {
            return .selected
        } else {
            return .notSelected
        }
    }
    
    func seekPlayerPosition(value: Float) {
        player?.seekTime(value: value)
    }
    
    func resizeFill(playerView: UIView) {
        player?.resizeFill(playerView: playerView)
    }
}

extension UIImage {
    func isEqualToImage(_ image: UIImage?) -> Bool {
        guard let image = image else { return false }
        return pngData() == image.pngData()
    }
}

extension DetailViewModel: AVvideoPlayerProtocol {
    
    func seekBarValue(min: Float, max: Float, value: Float) {
        delegate?.seekBarValue(min: min, max: max, value: value)
    }
    
    func sessionEnd() {
        delegate?.sessionEnd()
    }
    
    func thumbNailImage(thumb: UIImage) {
        delegate?.thumbNailImage(thumb: thumb)
    }
}

protocol DetailViewModelDelegate: class {
    func seekBarValue(min: Float, max: Float, value: Float)
    func sessionEnd()
    func thumbNailImage(thumb: UIImage)
}
