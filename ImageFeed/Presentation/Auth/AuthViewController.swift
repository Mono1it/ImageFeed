import UIKit
import ProgressHUD

enum SegueIdentifier {
    static let showWebView = "ShowWebView"
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueIdentifier.showWebView {
            guard
                let webViewVC = segue.destination as? WebViewViewController
            else {
                assertionFailure("❌ Failed to prepare for \(SegueIdentifier.showWebView)")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

// MARK: - Extension
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //vc.dismiss(animated: true) // Закрыли WebView
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let token):
                print("✅ Токен получен: \(token)")
                vc.dismiss(animated: true) { // Закрыли WebView
                    self.delegate?.didAuthenticate(self)
                    UIBlockingProgressHUD.dismiss()
                }
            case .failure(let error):
                print("❌ Ошибка авторизации: \(error.localizedDescription)")
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

