import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Private Constants
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        let imageName = "\(photosName[indexPath.row]).jpg"
        let image = UIImage(named: imageName)
        viewController.image = image
    }
    
    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = "\(photosName[indexPath.row]).jpg"
        
        guard let image = UIImage(named: imageName) else {
            print("⚠️ Картинка с именем \(imageName) не найдена.")
            return
        }
        // Установка изображения
        cell.cellImageView.image = image
        
        // Установка даты
        let dateString = dateFormatter.string(from: Date())
        cell.dateLabelView.text = dateString
        
        // Установка лайка
        let likeImageName = indexPath.row.isEven ? "Active" : "No Active"
        cell.likeButtonView.imageView?.image = UIImage(named: likeImageName)
    }
}

// MARK: - TableView Data Source extension
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Не удалось привести ячейку к нужному типу.")
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}

// MARK: - TableView Delegate extension
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = "\(photosName[indexPath.row]).jpg"
        
        // Получаем изображение по имени
        guard let image = UIImage(named: imageName) else {
            return 200
        }
        
        // Размеры изображения
        let imageSize = image.size
        
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
