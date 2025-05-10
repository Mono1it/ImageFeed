//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilya Shcherbakov on 10.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var gradientView: UIView!
    
    private var gradientLayer: CAGradientLayer?

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
