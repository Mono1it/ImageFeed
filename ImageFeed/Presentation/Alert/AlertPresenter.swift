import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var viewController: (UIViewController&AlertPresenterDelegate)?
    
    init(viewController: (UIViewController & AlertPresenterDelegate)? = nil) {
        self.viewController = viewController
    }
    
    func requestAlertPresenter(model: AlertModel?) {
        guard let model else { return }
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.viewController?.didAlertButtonTouch(alert: alert)
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
