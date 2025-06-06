//
//  Constants.swift
//  ImageFeed
//
//  Created by Ilya Shcherbakov on 27.05.2025.
//

import Foundation

enum Constants {
    static let accessKey = "qzJuk6n2d-3S7YrvQ_WhrvRbh6wdWq2NYmi0lJ8ZhBM"
    static let secretKey = "DcmU381jwFeKmox7c1j7pEvMLfzdSb6LeQFmSPSkED0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com") 
    // Оставил опцианальной, а не вычисляемой, так как эта переменная в коде ни разу не вызывалась. При вызове просто нужно будет распаковать опционал.
}

