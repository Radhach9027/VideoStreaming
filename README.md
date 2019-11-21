# VideoStreaming

Design Pattern: MVVM

Service: local JsonFIle

Player Controls:
Play, pause, replay ,timeline, thumbnails, full screen, orientation support.


Options:

Reachability check
Loading indicator while video is about load.
Able to see selected thumbnail with green check mark and bounce animation.
Scroll to selected thumbnail.
Tap on player to dismiss thumbnail.

Note: Two player were implemented and below are the details.

1.AVPlayerController
2.AVPlayer 

The second option is customized one, in order to user the first player need to uncomment few lines of code in "DetailViewController" and comment out the rest of the code.

    override func viewDidLoad() {
        super.viewDidLoad()

        // ******** Default player ********//
//        guard let url = model?.url else { return }
//        _ = AVPlayerController(url: url, controller: self)

        // ******** Custom player ********//
        viewModel = DetailViewModel(model: model, playerView: playerView, delegate: self)
        _ = thumNailCollection
        startStreaming()
    }
