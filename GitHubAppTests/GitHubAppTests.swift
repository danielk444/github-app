//
//  GitHubAppTests.swift
//  GitHubAppTests
//
//  Created by Daniel Kopanski on 12/07/2021.
//

import XCTest
import OHHTTPStubs
@testable import GitHubApp

class GitHubAppTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        HTTPStubs.removeAllStubs()
    }
    
    func testRepositoriesAreFetchedCorrectly() throws {
        // Given
        let query = "Alamofire"
        let page = 1
        
        stub(condition: isPath("/search/repositories?q=Alamofire&p=1")) { _ in
            let stubPath = OHPathForFile("repositories_response.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        // When
        GitHubService.searchForRepos(byQuery: query, page: page) { (wrapper) in
            XCTAssertEqual(wrapper.totalCount, 3046)
            XCTAssertEqual(wrapper.items.count, 3)
            
        } failure: { (message) in
            XCTFail(message)
        }
    }
    
    func testRepositoryResponseIsParsedCorrectly() throws {
        // Given
        let url = Bundle(for: GitHubAppTests.self).url(forResource: "repositories_response", withExtension: "json")!
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // When
        let repositories = try? decoder.decode(RepositoriesWrapper.self, from: data)

        // Then
        XCTAssertNotNil(repositories, "Repositories are null")
        XCTAssertEqual(repositories!.totalCount, 3046)
        XCTAssertEqual(repositories!.items.count, 3)
        XCTAssertEqual(repositories!.items[0].name, "Alamofire")
        XCTAssertEqual(repositories!.items[2].htmlUrl, "https://github.com/tristanhimmelman/AlamofireObjectMapper")
    }
}
