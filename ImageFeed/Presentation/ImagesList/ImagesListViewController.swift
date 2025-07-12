import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Variables
    var photos: [Photo] = []
    var notificationToken: NSObjectProtocol?

    // MARK: - Private Constants
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        notificationToken = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let self,
                let photos = notification.userInfo?["photos"] as? [Photo]
            else { return }
            
            print("📷 Обновлено: \(photos.count) элементов")
            self.photos = ImagesListService.shared.photos
            self.updateTableViewAnimated()
            self.tableView.reloadData()
        }
        // Запускаем первую загрузку
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        let photo = ImagesListService.shared.photos[indexPath.row]
        let imageURL = photo.largeImageURL
        guard
            let url = URL(string: imageURL) else {
            print("❌ Некорректный URL")
            return
        }

        viewController.imageURL = url
    }
    
    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = ImagesListService.shared.photos[indexPath.row]
        let imageURL = photo.thumbImageURL
        guard
            let url = URL(string: imageURL) else {
            print("❌ Некорректный URL")
            return
        }
        print("✅ Фото получено в configCell: \(indexPath.row)")
        cell.cellImageView.kf.indicatorType = .activity
        let imageUrl = url
        cell.cellImageView.kf.setImage(with: imageUrl,
                                     placeholder: UIImage(resource: .imagePlaceholder),
                                     options: nil)
        
        // Установка даты
        let dateString = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.dateLabelView.text = dateString
        
        // Установка лайков
        let isLike = photo.isLiked ? UIImage(resource: .active) : UIImage(resource: .noActive)
        cell.likeButtonView.imageView?.image = isLike
    }
    
    // Анимированное обновление таблицы
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

// MARK: - TableView Data Source extension
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
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
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

// MARK: - TableView Delegate extension
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = ImagesListService.shared.photos[indexPath.row]
        
        // Размеры изображения
        let imageSize = photo.size
        
        // Ширина экрана (или ячейки)
        let screenWidth = tableView.bounds.width
        
        // Высота с сохранением пропорций
        let imageViewHeight = imageSize.height * (screenWidth / imageSize.width)
        
        // Добавим отступы (cверху 4 и снизу 4)
        let verticalPadding: CGFloat = 8
        
        return imageViewHeight + verticalPadding
    }
}

// MARK: - Integer odd and even extention
extension Int {
    var isEven: Bool {
        self % 2 == 0
    }
    var isOdd: Bool {
        !isEven
    }
}

extension ImagesListViewController: LikeButtonDelegate {
    func didLikeButtonTouch(in cell: ImagesListCell) {
        // Поиск индекса элемента
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        // Текущий элемент
        let photo = photos[indexPath.row]
        let newValue = !photo.isLiked
        
        // Обновляем UI кнопки
        cell.setLike(isLike: newValue)
        UIBlockingProgressHUD.show()
        
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: newValue) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.photos[indexPath.row] = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: newValue
                )
                // Обновляем список фотографий в сервисе, чтобы при прокрутке вниз списка лайки не исчезали сверху
                ImagesListService.shared.updateLikeStatus(photoId: photo.id, isLiked: newValue)
                UIBlockingProgressHUD.dismiss()
                print("✅ Поставлен лайк/дизлайк фото с id: \(photo.id)")
            case .failure(let error):
                print("❌ Не удалось изменить лайк: \(error)")
                UIBlockingProgressHUD.dismiss()
                DispatchQueue.main.async {
                    cell.setLike(isLike: photo.isLiked)
                }
            }
        }
    }
}

