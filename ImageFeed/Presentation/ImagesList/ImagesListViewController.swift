//
//  ViewController.swift
//  ImageFeed
//
//  Created by Ilya Shcherbakov on 28.04.2025.
//

import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Не удалось привести ячейку к нужному типу.")
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell)
        return imagesListCell
    }
    
    
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell) {
        
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}
