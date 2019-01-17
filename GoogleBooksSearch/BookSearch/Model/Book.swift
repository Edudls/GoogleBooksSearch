//
//  Book.swift
//  BookSearch
//
//  Created by DMonaghan on 1/10/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import Foundation
import Unbox

struct Book {
    let identifier: String
    let title: String
    let authors: [String]?
    let thumbnail: String?
    var isFavorite: Bool = false
    
    /*init(title: String, author: String, thumbnail: String) {
        self.title = title
        self.author = author
        self.thumbnail = thumbnail
    }*/
}

extension Book: Unboxable {
    init(unboxer: Unboxer) throws {
        self.identifier = try unboxer.unbox(key: "id")
        self.title = try unboxer.unbox(keyPath: "volumeInfo.title")
        self.authors = unboxer.unbox(keyPath: "volumeInfo.authors")
        self.thumbnail = unboxer.unbox(keyPath: "volumeInfo.imageLinks.thumbnail")
    }
}
