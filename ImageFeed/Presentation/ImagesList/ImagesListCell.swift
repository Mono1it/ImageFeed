//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilya Shcherbakov on 10.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var dateLabelView: UILabel!
    @IBOutlet weak var likeButtonView: UIButton!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Overrides Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Удаляем старый градиент (если есть)
        gradientLayer?.removeFromSuperlayer()
        
        // Создаём новый градиент
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.ypBlack.withAlphaComponent(0.6).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.frame = gradientView.bounds
        
        // Добавляем
        gradientView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
}
