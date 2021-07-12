//
//  RepositoriesWrapper.swift
//  GitHubApp
//
//  Created by Daniel Kopanski on 12/07/2021.
//

struct RepositoriesWrapper: Decodable {
    let totalCount: Int
    let items: [Repository]
}
