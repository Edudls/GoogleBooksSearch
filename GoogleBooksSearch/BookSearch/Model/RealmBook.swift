//
//  RealmBook.swift
//  BookSearch
//
//  Created by DMonaghan on 1/15/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import UIKit
import RealmSwift

class RealmBook: Object {
    @objc dynamic var identifier: String = ""
    //@objc dynamic var title: String = ""
    //@objc dynamic var authors: [String]? = []
    //@objc dynamic var thumbnail: String? = ""
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    static func create(using book: Book) -> RealmBook {
        let realmBook = RealmBook()
        realmBook.identifier = book.identifier
        //realmBook.title = book.title
        //realmBook.authors = book.authors
        //realmBook.thumbnail = book.thumbnail
        
        return realmBook
    }
}
