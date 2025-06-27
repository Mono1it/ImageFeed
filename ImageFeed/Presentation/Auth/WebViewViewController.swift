import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    // MARK: - Private Constants
    private let accuracyThreshold = 0.0001
    private var estimatedProgressObservation: NSKeyValueObservation?
    // MARK: - Delegate
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var progressBarView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        loadWebView()
        
        updateProgress()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _  in
                 guard let self else { return }
                 self.updateProgress()
             })
    }
    
    // MARK: - Private Methods
    private func updateProgress() {
        progressBarView.progress = Float(webView.estimatedProgress)
        progressBarView.isHidden = fabs(webView.estimatedProgress - 1.0) <= accuracyThreshold
    }
    
    private func loadWebView() {
        var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        if let url = urlComponents?.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// MARK: - Extensions
extension WebViewViewController:WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = fetchCode(from: navigationAction.request.url) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func fetchCode(from url: URL?) -> String? {
        guard
            let url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        
        return codeItem.value
    }
}
