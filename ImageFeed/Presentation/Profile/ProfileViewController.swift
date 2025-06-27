import UIKit
import ProgressHUD
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var userName = "Екатерина Новикова"
    private var userLogin = "@ekaterina_nov"
    private var userDiscription = "Hello, world!"
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - UI Elements
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        //label.text = userName     //  Убрал мок данные
        label.textColor = UIColor(resource: .ypWhite)
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        //label.text = userLogin    //  Убрал мок данные
        label.textColor = UIColor(resource: .ypGray)
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        //label.text = userDiscription  //  Убрал мок данные
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
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(with: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateProfileAvatar()
        }
        
        updateProfileAvatar()
        setupUI()
        setupProfileImageView()
        setupNameLabel()
        setupNicknameLabel()
        setupDescriptionLabel()
        setupExitButton()
    }
    
    // MARK: - Setup Functions
    private func updateProfileAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL) else {
            print("❌ Некорректный URL")
            return
        }
        print("✅ Аватарка получена в updateProfileAvatar: \(url)")
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.indicatorType = .activity
        let imageUrl = url
        profileImageView.kf.setImage(with: imageUrl,
                                     placeholder: UIImage(resource: .emptyProfile),
                                     options: [.processor(processor)])
    }
    
    private func updateProfileDetails(with profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        nickNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
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
    
    // MARK: - Actions
    @objc private func didTapExitButton() {
        print("🚪 Выход")
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
