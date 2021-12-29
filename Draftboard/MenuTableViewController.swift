//
//  MenuTableViewController.swift
//  Draftboard
//
//  Created by Hans Wang on 5/15/21.
//

import UIKit

let CellReuseId = "MenuCell"

@objc protocol MenuDelegate {
    func cleanBoard()
}

class MenuTableViewController: UITableViewController {
    weak var delegate: MenuDelegate?
    var rows: [MenuRow] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize.init(width: 200, height: 44)
        tableView.rowHeight = 44
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseId)
        self.rows = [
            .init(title: "Clean Board", image: UIImage(systemName: "trash")!, imgTint: .systemGreen, action: {
                print("on click - clean board")
                let alert = UIAlertController(title: "Do you want to clean the board?", message: "Once cleaned the drawing won't be able to restore.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.delegate?.cleanBoard()
                    self.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            })
        ]
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
