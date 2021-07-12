//
//  ViewController.swift
//  GitHubApp
//
//  Created by Daniel Kopanski on 12/07/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    private let minQueryLength = 3
    
    private var repositories: [Repository] = []
    private var page = 0
    private var repositoriesCount = 0
    private var canLoadNextPage = true
    
    private func displayErrorAlert(_ errorMessage: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    private func searchForRepos() {
        guard let query = searchBar.text, query.count >= minQueryLength else { return }
        GitHubService.searchForRepos(byQuery: query, page: page, completion: { wrapper in
            self.repositoriesCount = wrapper.totalCount
            if self.page == 0 {
                self.repositories = wrapper.items
            } else {
                self.repositories.append(contentsOf: wrapper.items)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.canLoadNextPage = true
        }) { errorMessage in
            self.displayErrorAlert(errorMessage)
            self.canLoadNextPage = true
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        cell.setup(repositoryName: repositories[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: repositories[indexPath.row].htmlUrl) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        guard scrollView == tableView, canLoadNextPage, repositoriesCount > repositories.count else { return }
        let maxYOffset = (scrollView.contentSize.height - scrollView.bounds.height) - 20
        if scrollView.contentOffset.y > maxYOffset {
            canLoadNextPage = false
            page += 1
            searchForRepos()
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count >= minQueryLength else { return }
        repositoriesCount = 0
        page = 0
        searchForRepos()
    }
}
