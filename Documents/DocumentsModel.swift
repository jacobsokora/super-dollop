//
//  DocumentsModel.swift
//  Documents
//
//  Created by Jacob Sokora on 9/9/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import CloudKit

class DocumentsModel {
    private let database = CKContainer.default().privateCloudDatabase
    
    var onChange : (() -> Void)?
    var onError : ((Error) -> Void)?
    var notificationQueue = OperationQueue.main
    
    var documents = [Document]() {
        didSet {
            self.notificationQueue.addOperation {
                self.onChange?()
            }
        }
    }
    
    var records = [CKRecord]()
    var insertedObjects = [Document]()
    var deletedObjectIds = Set<CKRecordID>()
    
    private func handle(error: Error) {
        self.notificationQueue.addOperation {
            self.onError?(error)
        }
    }
    
    @objc func refresh() {
        let query = CKQuery(recordType: Document.recordType, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                self.handle(error: error!)
                return
            }
            
            self.records = records
            self.updateDocuments()
            self.documents = records.map { record in Document(record: record) }
        }
    }
    
    func addDocument(title: String, content: String) {
        var document = Document()
        document.title = title
        document.content = content
        database.save(document.record) { _, error in
            guard error == nil else {
                self.handle(error: error!)
                return
            }
        }
        insertedObjects.append(document)
        updateDocuments()
    }
    
    func delete(at index : Int) {
        let recordId = self.documents[index].record.recordID
        database.delete(withRecordID: recordId) { _, error in
            guard error == nil else {
                self.handle(error: error!)
                return
            }
        }
        deletedObjectIds.insert(recordId)
        updateDocuments()
    }
    
    func updateDocuments() {
        var knownIds = Set(records.map {$0.recordID })
        
        insertedObjects = insertedObjects.filter{ !knownIds.contains($0.record.recordID) }
        
        knownIds.formUnion(insertedObjects.map { $0.record.recordID })
        
        deletedObjectIds.formIntersection(knownIds)
        
        var documents = records.map { record in Document(record: record) }
        
        documents.append(contentsOf: insertedObjects)
        documents = documents.filter{ !deletedObjectIds.contains($0.record.recordID) }
        
        self.documents = documents
        
        debugPrint("Tracking local objects \(insertedObjects) \(deletedObjectIds)")
    }
}

struct Document {
    fileprivate static let recordType = "Document"
    fileprivate static let keys = (title: "title", content: "content", modified: "modifiedAt")
    
    var record: CKRecord
    
    init(record: CKRecord) {
        self.record = record
    }
    
    init() {
        self.record = CKRecord(recordType: Document.recordType)
    }
    
    var title: String {
        get {
            return self.record.value(forKey: Document.keys.title) as! String
        }
        set {
            self.record.setValue(newValue, forKey: Document.keys.title)
        }
    }
    
    var content: String {
        get {
            return self.record.value(forKey: Document.keys.content) as! String
        }
        set {
            self.record.setValue(newValue, forKey: Document.keys.content)
        }
    }
    
    var modified: Date? {
        get {
            return record.modificationDate
        }
    }
}
