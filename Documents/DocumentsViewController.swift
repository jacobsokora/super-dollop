//
//  ViewController.swift
//  Documents
//
//  Created by Jacob Sokora on 6/9/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController {
    
    @IBOutlet weak var documentsTableView: UITableView!

    let dateFormatter = DateFormatter()
    
    let model = DocumentsModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        documentsTableView.dataSource = self
        documentsTableView.delegate = self
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
    
        model.onError = { error in
            print(error.localizedDescription)
        }
        model.refresh()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        documentsTableView.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        model.refresh()
        documentsTableView.refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        documentsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EditDocumentViewController {
            if let selected = documentsTableView.indexPathForSelectedRow {
                let document = model.documents[selected.row]
                destination.document = document
            }
            destination.model = model
        }
    }
}

extension DocumentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentsTableViewCell
        let document = model.documents[indexPath.row]
        cell.nameLabel.text = document.title
        cell.sizeLabel.text = "\(document.content.lengthOfBytes(using: .utf8)) bytes"
        cell.timeLabel.text = "Modified: \(dateFormatter.string(from: document.modified ?? Date()))"
        return cell
    }
}

extension DocumentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.model.delete(at: indexPath.row)
            success(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
