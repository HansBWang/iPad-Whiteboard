//
//  MenuTableViewController.swift
//  InterviewWhiteboard
//
//  Created by Hans Wang on 5/15/21.
//

import UIKit

let CellReuseId = "MenuCell"

class MenuTableViewController: UITableViewController {
    let rows: [MenuRow] = [
        .init(title: "Clean Board", image: UIImage(systemName: "trash")!, imgTint: .systemGreen, action: {
            print("on click - clean board")
        })
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize.init(width: 200, height: 44)
        tableView.rowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseId)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        rows[indexPath.row].action()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId, for: indexPath)
        cell.textLabel?.text = rows[indexPath.row].title
        cell.imageView?.image = rows[indexPath.row].image
        cell.imageView?.tintColor = rows[indexPath.row].imgTint
        return cell
    }
}

extension MenuTableViewController {
    struct MenuRow {
        let title: String
        let image: UIImage
        let imgTint: UIColor
        let action: (() -> Void)
    }
}
