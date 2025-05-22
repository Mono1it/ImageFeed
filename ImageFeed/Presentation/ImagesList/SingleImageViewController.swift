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
            guard let image = image else {return}
            rescaleAndCenterImage(image: image)
        }
    }
    

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak private var imageView: UIImageView!
    

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else {
            print("⚠️ Нет изображения для шаринга")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = image else {return}
        imageView.image = image
        rescaleAndCenterImage(image: image)
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 2
    }
    
    func rescaleAndCenterImage(image: UIImage) {
        let imageSize = image.size
        let visibleRectSize = scrollView.bounds.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let theoreticalScale = min(hScale, vScale)
        let Scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, theoreticalScale))
        self.scrollView.setZoomScale(Scale, animated: false)
        scrollView.layoutIfNeeded()

        centerImage()
    }
    
    func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
