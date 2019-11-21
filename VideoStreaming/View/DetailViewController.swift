import UIKit

enum SystemImages: String {
    case pause
    case playFull
    case maximize
    case minimize
    case thumbNail
    case thumbNailSelected
    case replay
    case check
}

class DetailViewController: UIViewController {
    deinit {
        print("DetailViewController deallocated")
    }

    @IBOutlet var playerView: UIView!
    @IBOutlet var playerControlView: UIView!
    @IBOutlet var play_pause: UIButton!
    @IBOutlet var seekBar: UISlider!
    @IBOutlet var timeIn: UILabel!
    @IBOutlet var timeOut: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var min_maxbutton: UIButton!
    @IBOutlet var thumbNailsList: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var heightContraint: NSLayoutConstraint!
    var thumbHeightContraint: NSLayoutConstraint?

    var model: ThumbNailModel?
    var viewModel: DetailViewModel?

    fileprivate weak var thumNailCollection: ThumbNailView? {
        let thumbNail = ThumbNailView(direction: .horizontal, size: CGSize(width: 80, height: 80), viewModel: ThumbNailViewModel(), selectedObj: model)
        thumbNail.delegate = self
        thumbNail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(thumbNail)
        thumbNail.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        thumbNail.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        thumbNail.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        thumbHeightContraint = thumbNail.heightAnchor.constraint(equalToConstant: 0)
        thumbHeightContraint?.isActive = true
        return thumbNail
    }

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

    private func startStreaming() {
        setViewObjects(model: model)
        playButtonTapped(play_pause)
    }

    private func setViewObjects(model: ThumbNailModel?) {
        guard let thumbNail = model else { return }
        descriptionLabel.text = thumbNail.description
        title = thumbNail.title
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
           showNavigationBar(show: true)
           playerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        } else {
            resizeView(min: true)
            showNavigationBar(show: false)
        }
        viewModel?.resizeFill(playerView: playerView)
    }

    private func resizeView(min: Bool) {
        UIView.animate(withDuration: 0.2) {
            if min {
                self.heightContraint.constant = 300
            } else {
                self.heightContraint.constant = UIScreen.main.bounds.size.height
            }
        }
        view.layoutIfNeeded()
    }

    private func showIndicator(show: Bool) {
        DispatchQueue.main.async { [weak self] in
            if show {
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
            }
        }
    }

    private func showNavigationBar(show: Bool) {
        navigationController?.isNavigationBarHidden = UIDevice.current.orientation.isLandscape ? true : show
    }
}

extension DetailViewController {
    @IBAction func resizeScreen(_ sender: UIButton) {
        switch viewModel?.playerResized(state: sender) {
        case .selected:
            showNavigationBar(show: true)
            sender.setImage(UIImage(named: SystemImages.minimize.rawValue), for: .normal)
            resizeView(min: false)
        default:
            showNavigationBar(show: false)
            sender.setImage(UIImage(named: SystemImages.maximize.rawValue), for: .normal)
            resizeView(min: true)
        }
        viewModel?.resizeFill(playerView: playerView)
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        switch viewModel?.playerStates(state: sender) {
        case .play:
            sender.setImage(UIImage(named: SystemImages.pause.rawValue), for: .normal)
            showIndicator(show: true)
            viewModel?.play()
        case .pause:
            sender.setImage(UIImage(named: SystemImages.playFull.rawValue), for: .normal)
            viewModel?.pause()
        case .replay:
            sender.setImage(UIImage(named: SystemImages.pause.rawValue), for: .normal)
            showIndicator(show: true)
            viewModel?.replay()
        default:
            break
        }
    }

    @IBAction func seekBarDragged(_ sender: UISlider) {
        showIndicator(show: true)
        viewModel?.seekPlayerPosition(value: sender.value, duration: sender.maximumValue)
    }

    @IBAction func playerTapped(_ sender: UITapGestureRecognizer) {
        playerControlView.isHidden = false
        thumbNailsList.setImage(UIImage(named: SystemImages.thumbNailSelected.rawValue), for: .normal)
        thumbNailsTapped(thumbNailsList)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.playerControlView.isHidden = true
        }
    }

    @IBAction func thumbNailsTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            switch self?.viewModel?.playerThumbNailSelection(state: sender) {
            case .selected:
                self?.thumbHeightContraint?.constant = 160
                sender.setImage(UIImage(named: SystemImages.thumbNailSelected.rawValue), for: .normal)
            case .notSelected:
                self?.thumbHeightContraint?.constant = 0
                sender.setImage(UIImage(named: SystemImages.thumbNail.rawValue), for: .normal)
            default:
                break
            }
        }
        view.layoutIfNeeded()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        viewModel?.stop()
        navigationController?.popViewController(animated: true)
    }
}

extension DetailViewController: DetailViewModelDelegate {
    func seekBarValue(min: Float, max: Float, value: Float) {
        seekBar.minimumValue = 0
        seekBar.maximumValue = max.isNaN ? 0 : max
        seekBar.value = value.isNaN ? 0 : value
        timeIn.text = String(format: "%02d:%02d", Int(min.isNaN ? 0 : min) / 60, Int(min.isNaN ? 0 : min) % 60)
        timeOut.text = String(format: "%02d:%02d", Int(max.isNaN ? 0 : max) / 60, Int(max.isNaN ? 0 : max) % 60)
    }

    func sessionEnd() {
        play_pause.setImage(UIImage(named: SystemImages.replay.rawValue), for: .normal)
    }

    func thumbNailImage(thumb: UIImage) {}

    func isPlaying() {
        showIndicator(show: false)
        play_pause.setImage(UIImage(named: SystemImages.pause.rawValue), for: .normal)
    }
}

extension DetailViewController: ThumbProtocol {
    func selectedThumNail(model: ThumbNailModel) {
        showIndicator(show: true)
        setViewObjects(model: model)
        viewModel?.playSelectedVideo(model: model, playerView: playerView)
    }
}
