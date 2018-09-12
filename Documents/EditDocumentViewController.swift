//
//  EditDocumentViewController.swift
//  Documents
//
//  Created by Jacob Sokora on 6/9/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit
import CoreData

class EditDocumentViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var documentArea: UITextView!
    
    var document: Document?
    var model: DocumentsModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let document = document else {
            return
        }
        
        nameField.text = document.title
        documentArea.text = document.content
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveFile(_ sender: Any) {
        guard let fileName = nameField.text, fileName.count > 0, let content = documentArea.text, content.count > 0 else {
            return
        }
        if var document = document {
            document.title = fileName
            document.content = content
        } else if let model = model {
            model.addDocument(title: fileName, content: content)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
         self.title = nameField.text ?? "New Document"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
