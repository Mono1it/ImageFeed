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
    
    @IBOutlet weak private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
