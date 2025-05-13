//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilya Shcherbakov on 12.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func didTouchExitButton(_ sender: Any) {
    }
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var profilePhotoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
}
