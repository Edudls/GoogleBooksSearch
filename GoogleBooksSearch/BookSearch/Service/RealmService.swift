//
//  RealmService.swift
//  BookSearch
//
//  Created by DMonaghan on 1/15/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    func save(book: Book) {
        DispatchQueue.global(qos: .utility).async {
            let realm = try! Realm()
            let realmBook = RealmBook.create(using: book)
            
            try! realm.write {
                realm.add(realmBook)
            }
        }
    }
    
    func remove(book: Book) {
        DispatchQueue.global(qos: .utility).async {
            let realm = try! Realm()
            let realmBook = realm.objects(RealmBook.self).filter("identifier = %@", book.identifier)
            
            try! realm.write {
                realm.delete(realmBook)
            }
        }
    }
    
    
    typealias Handler = ([String]) -> ()
    
    func getBooks(completion: @escaping Handler) {
        DispatchQueue.main.async {
            var books: [String] = []
            let realm = try! Realm()
            
            let bookObjects = realm.objects(RealmBook.self)
            print(bookObjects)
            books = Array(bookObjects.map{$0.identifier})
            completion(books)
        }
    }
}
