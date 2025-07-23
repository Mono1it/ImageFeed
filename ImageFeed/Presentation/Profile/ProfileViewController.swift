import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func showLogoutAlert()
    func updateProfileAvatar(with url: URL)
    func showSplashScreen()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    // MARK: - UI Elements
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .ypWhite)
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .ypGray)
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .ypWhite)
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyProfile)
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .exit),
            target: self,
            action: #selector(didTapExitButton)
        )
        button.tintColor = UIColor(resource: .ypRed)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 🔓 Для UI тестов
        nameLabel.accessibilityIdentifier = "profileName"
        nickNameLabel.accessibilityIdentifier = "profileUsername"
        exitButton.accessibilityIdentifier = "logoutButton"
        
        presenter?.viewDidLoad()

        setupUI()
        setupProfileImageView()
        setupNameLabel()
        setupNicknameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    // MARK: - Actions
    @objc func didTapExitButton() {
        presenter?.didTapLogout()
    }

    // MARK: - Methods
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        nickNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func updateProfileAvatar(with url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.indicatorType = .activity
        let imageUrl = url
        profileImageView.kf.setImage(with: imageUrl,
                                     placeholder: UIImage(resource: .emptyProfile),
                                     options: [.processor(processor)])
    }
    
    func showLogoutAlert() {
        //  создаём модель alert
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.presenter?.confirmLogout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: {})
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: {})
    }
    
    func showSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        print(String("Current View Controller: \(window.rootViewController)"))
        print("🚪 Выход")
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(profileImageView, nameLabel, nickNameLabel, descriptionLabel, exitButton)
        view.backgroundColor = UIColor(resource: .ypBlack)
    }
    
    private func setupProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupNameLabel() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor)
        ])
    }
    
    private func setupNicknameLabel() {
        NSLayoutConstraint.activate([
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nickNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
    
    private func setupDescriptionLabel() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nickNameLabel.leadingAnchor)
        ])
    }
    
    private func setupExitButton() {
        NSLayoutConstraint.activate([
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
}
// MARK: - Extensions
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}
