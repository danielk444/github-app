//
//  TableViewCell.swift
//  GitHubApp
//
//  Created by Daniel Kopanski on 12/07/2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var repositoryLabel: UILabel!
    
    func setup(repositoryName: String) {
        repositoryLabel.text = repositoryName
    }
}
