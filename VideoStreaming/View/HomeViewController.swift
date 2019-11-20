import UIKit

class HomeViewController: UIViewController {

    fileprivate weak var thumNailCollection: ThumbNailView? {
        let thumbNail = ThumbNailView(size: CGSize(width: 180, height: 180), viewModel: ThumbNailViewModel(), selectedObj: nil)
        thumbNail.delegate = self
        thumbNail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(thumbNail)
        thumbNail.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        thumbNail.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        thumbNail.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        thumbNail.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        return thumbNail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = thumNailCollection
    }
}

extension HomeViewController: ThumbProtocol {
    func selectedThumNail(model: ThumbNailModel) {
        if let detailsVc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailsVc.model = model
            self.navigationController?.pushViewController(detailsVc, animated: true)
        }
    }
}


