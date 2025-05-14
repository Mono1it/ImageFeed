//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Ilya Shcherbakov on 13.05.2025.
//

import UIKit
    
final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet{
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        if let image = image {
                imageView.frame.size = image.size
            }
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
