import Foundation

enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(Error)
    case invalidRequest
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let data):
                    do {
                        let response = try decoder.decode(T.self, from: data)
                        completion(.success(response)) // Успешно декодировали
                    } catch {
                        print("❌ Ошибка декодирования в URLSession: \(error.localizedDescription)")
                        completion(.failure(NetworkError.decodingError(error))) // Ошибка при декодировании
                    }
                    
                case .failure(let error):
                    if case let NetworkError.httpStatusCode(code) = error {
                        print("❌ Unsplash вернул ошибку. Код: \(code)")
                    } else {
                        print("❌ Ошибка в URLSession: \(error.localizedDescription)")
                    }
                    completion(.failure(error)) // Ошибка сети
                }
            }
        }
        return task
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        
        return task
    }
}
