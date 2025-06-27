import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didAlertButtonTouch(alert: UIAlertController?)
}
