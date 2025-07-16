import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func showImageViewer(with url: URL)
    func insertRows(at indexPaths: [IndexPath])
    func setLikeUI(at indexPath: IndexPath, isLiked: Bool)
    func showProgressHUD()
    func hideProgressHUD()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    var presenter: ImagesListPresenterProtocol?
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - Private Constants
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let url = sender as? URL else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        viewController.imageURL = url
    }
    
    // MARK: - Public Methods
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showImageViewer(with url: URL) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: url)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let url = presenter?.imageURL(for: indexPath) else {
            print("❌ Некорректный URL")
            return
        }

        print("✅ Фото получено в configCell: \(indexPath.row)")
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .imagePlaceholder),
            options: nil
        )
        
        cell.dateLabelView.text = presenter?.formattedDate(for: indexPath)
        
        let isLiked = presenter?.isLiked(for: indexPath) ?? false
        cell.likeButtonView.imageView?.image = isLiked
            ? UIImage(resource: .active)
            : UIImage(resource: .noActive)
    }
}

// MARK: - TableView Data Source extension
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Не удалось привести ячейку к нужному типу.")
            return UITableViewCell()
        }
        
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.cellDidDisplay(at: indexPath)
    }
}

// MARK: - TableView Delegate extension
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectImage(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Размеры изображения
        let imageSize = presenter?.imageSize(at: indexPath) ?? .zero
        
        // Ширина экрана (или ячейки)
        let screenWidth = tableView.bounds.width
        
        // Высота с сохранением пропорций
        let imageViewHeight = imageSize.height * (screenWidth / imageSize.width)
        
        // Добавим отступы (cверху 4 и снизу 4)
        let verticalPadding: CGFloat = 8
        
        return imageViewHeight + verticalPadding
    }
}

// MARK: - LikeButton extention
extension ImagesListViewController: LikeButtonDelegate {
    func showProgressHUD() {
        UIBlockingProgressHUD.show()
    }
    
    func hideProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func setLikeUI(at indexPath: IndexPath, isLiked: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.setLike(isLike: isLiked)
        }
    }
    
    func didLikeButtonTouch(in cell: ImagesListCell) {
        // Поиск индекса элемента
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        presenter?.didLikeButtonTap(at: indexPath)
    }
}

