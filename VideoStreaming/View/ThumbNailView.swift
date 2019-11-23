import UIKit

protocol ThumbProtocol: class {
    func selectedThumNail(model: ThumbNailModel)
}

class ThumbNailView: UIView {
    weak var delegate: ThumbProtocol?
    private var direction: UICollectionView.ScrollDirection
    private var size: CGSize
    private var viewModel: ThumbNailViewModel?
    private var selectedObj: ThumbNailModel?
    private var collectionView: UICollectionView?

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    init(direction: UICollectionView.ScrollDirection = .vertical, size: CGSize = CGSize(width: 150, height: 150), viewModel: ThumbNailViewModel?, selectedObj: ThumbNailModel?) {
        self.direction = direction
        self.size = size
        self.viewModel = viewModel
        self.selectedObj = selectedObj
        super.init(frame: CGRect.zero)
        addCollectionView()
    }
}

private extension ThumbNailView {
    func addCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = size
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(ThumbNailCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomAnchor, multiplier: 1).isActive = true
    }

    func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }

    func scrollToRespectiveIndex() {
        if let indexPath = viewModel?.index(selectedObj!) {
            collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension ThumbNailView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberItemsSections ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ThumbNailCell
        if let modelObj = viewModel?.data?[indexPath.row] {
            cell.setValues(data: modelObj, selectedObj: selectedObj)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let obj = viewModel?.data?[indexPath.item] {
            selectedObj = obj
            reload()
            scrollToRespectiveIndex()
            delegate?.selectedThumNail(model: obj)
        }
    }
}
