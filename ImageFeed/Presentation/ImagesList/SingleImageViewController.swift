import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    var imageURL: URL?
    var image: UIImage? {
        didSet{
            guard isViewLoaded else { return }
            imageView.image = image
            guard let image = image else { return }
            rescaleAndCenterImage(image: image)
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    
    // MARK: - IBAction
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {
            print("⚠️ Нет изображения для шаринга")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 2
        
        if let url = imageURL {
            setupImage(imageView: imageView, url: url)
        }
    }
    
    // MARK: - Private Methods
    private func rescaleAndCenterImage(image: UIImage) {
        // Устанавливаем изображение и размер
        imageView.image = image
        imageView.sizeToFit()
        scrollView.contentSize = imageView.bounds.size
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = minScale
        
        centerImage()
        
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

// MARK: - Extensions
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    // MARK: - Public methods
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    func setupImage(imageView: UIImageView, url: URL) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImage(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    func showError() {
        //  создаём модель alert
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Попробовать ещё раз?",
                                      preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Повторить", style: .default) {[weak self] _ in
            guard let self else { return }
            guard let url = self.imageURL  else { return }
            self.setupImage(imageView: self.imageView, url: url)
        }
        
        let noAction = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true, completion: {})
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: {})
    }
}

