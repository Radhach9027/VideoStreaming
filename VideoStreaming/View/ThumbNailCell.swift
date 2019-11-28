import UIKit

class ThumbNailCell: UICollectionViewCell {
    deinit {
        print("ThumbNailCell deallocated")
    }

    func setValues(data: ThumbNailModel?, selectedObj: ThumbNailModel?) {
        guard let data = data else { return }
        backGround.load(url: URL(string: data.thumbnail)!)
        selectionImage.image = UIImage(named: (data.id == selectedObj?.id) ? SystemImages.check.rawValue : "")
        isHighlighted = (data.id == selectedObj?.id) ? true : false
        title.text = data.title
    }

    fileprivate lazy var backGround: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 10
        return image
    }()

    fileprivate lazy var selectionImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()

    fileprivate lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, family: .medium)
        label.backgroundColor = .black
        label.alpha = 0.7
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(backGround)
        backGround.addSubview(title)
        backGround.addSubview(selectionImage)

        backGround.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backGround.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        backGround.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        backGround.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        selectionImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        selectionImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        selectionImage.heightAnchor.constraint(equalToConstant: 18).isActive = true
        selectionImage.widthAnchor.constraint(equalToConstant: 18).isActive = true

        title.leftAnchor.constraint(equalTo: backGround.leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: backGround.rightAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: backGround.bottomAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ThumbNailCell {
    override var isHighlighted: Bool {
        didSet { bounce(isHighlighted) }
    }

    func bounce(_ bounce: Bool) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { self.transform = bounce ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity },
            completion: nil)
    }
}

extension UIFont {
    enum Family: String {
        case medium = "KohinoorTelugu-Medium"
        case regular = "KohinoorTelugu-Regular"
    }

    class func customFont(ofSize size: CGFloat, family: Family) -> UIFont {
        return UIFont(name: family.rawValue, size: size)!
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
