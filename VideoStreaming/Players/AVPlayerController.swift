import AVKit
import UIKit

class AVPlayerController: NSObject {
    deinit {
        print("AVPlayerController  deallocated")
    }

    private var moviePlayer: AVPlayerViewController?

    init(url: String, controller: UIViewController) {
        super.init()
        guard let playerUrl = URL(string: url) else { return }
        let player = AVPlayer(url: playerUrl)
        moviePlayer = AVPlayerViewController()
        moviePlayer?.player = player
        controller.present(moviePlayer!, animated: true) {
            self.moviePlayer?.player!.play()
        }
    }
}
