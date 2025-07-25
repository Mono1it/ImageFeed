import UIKit

protocol LikeButtonDelegate: AnyObject {
    func didLikeButtonTouch(in cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var likeButtonView: UIButton!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: LikeButtonDelegate?
    
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Удаляем старый градиент (если есть)
        gradientLayer?.removeFromSuperlayer()
        
        // Создаём новый градиент
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.ypBlack.withAlphaComponent(0.6).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.frame = gradientView.bounds
        
        // Добавляем
        gradientView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    // MARK: - IBActions
    @IBAction func didLikeButtonTouch(_ sender: Any) {
        delegate?.didLikeButtonTouch(in: self)
    }
    
    func setLike(isLike: Bool) {
        // Установка лайка
        let image = isLike ? UIImage(resource: .active) : UIImage(resource: .noActive)
        likeButtonView.setImage(image, for: .normal)
        
        // ✅ Accessibility для UI-тестов
            likeButtonView.accessibilityIdentifier = "like button"
            likeButtonView.accessibilityValue = isLike ? "liked" : "not liked"
    }
}
