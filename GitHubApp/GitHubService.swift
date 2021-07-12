//
//  GitHubService.swift
//  GitHubApp
//
//  Created by Daniel Kopanski on 12/07/2021.
//

import Foundation

struct GitHubService {
    
    private static let searchApiURL = "https://api.github.com/search/repositories"
    
    private static var searchReposTask: URLSessionDataTask?
    
    static func searchForRepos(byQuery query: String, page: Int, completion: @escaping (RepositoriesWrapper) -> (), failure: @escaping (String) -> ()) {
        guard var urlComponents = URLComponents(string: searchApiURL) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = urlComponents.url else { return }
        
        if let task = searchReposTask, task.state == .running {
            task.cancel()
        }
        
        searchReposTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                if error?._code != NSURLErrorCancelled {
                    failure(error?.localizedDescription ?? "")
                }
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard statusCode == 200 else {
                failure("Code: \(String(describing: statusCode))")
                return
            }
            
            guard let data = data else {
                failure("Corrupted data")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let wrapper = try? decoder.decode(RepositoriesWrapper.self, from: data) else {
                failure("Invalid data format")
                return
            }
            
            completion(wrapper)
        }
        
        searchReposTask?.resume()
    }
}

