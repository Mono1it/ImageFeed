import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: ImageFeed.WebViewViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func fetchCode(from url: URL) -> String? {
        return nil
    }
}
