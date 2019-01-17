//
//  NetworkService.swift
//  BookSearch
//
//  Created by DMonaghan on 1/10/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import Foundation
import Alamofire
import Unbox

class NetworkService {
    
    let searchURL = "https://www.googleapis.com/books/v1/volumes?q="
    let volumeURL = "https://www.googleapis.com/books/v1/volumes/"
    // API key is not working, so I am omitting it for now
    let apiKey = "&key=AIzaSyBbdQHd1QQofSLfDF0wpoVqtsBbq7usfF4"
    
    typealias Handler = ([Book]) -> ()
    
    func search(for text: String, completion: @escaping Handler) {
        
        //print(text)
        Alamofire.request(searchURL + text).responseJSON() { response in
            
            guard let value = response.result.value else {
                print("data response failed")
                return
            }
            
            //print(value)
            let dict = value as! [String:Any]
            
            guard let books : [Book] = try? unbox(dictionary: dict, atKey: "items") else {
                print("unboxing failed")
                return
            }
            
            //print(books)
            completion(books)
        }
        
    }
    
    func getFavs(with volumeIDs: [String], completion: @escaping Handler) {
        
        var books: [Book] = []
        
        for id in volumeIDs {
            Alamofire.request(volumeURL + id).responseJSON() { response in
                guard let value = response.result.value else {
                    print("data response failed")
                    return
                }
                
                let dict = value as! [String: Any]
                
                guard let book: Book = try? unbox(dictionary: dict) else {
                    print("unboxing failed")
                    return
                }
                
                books.append(book)
                print(book)
            }
        }
        completion(books)
    }
    
    func getBook(with volumeID: String, completion: @escaping (Book) -> () ) {
        Alamofire.request(volumeURL + volumeID).responseJSON() { response in
            guard let value = response.result.value else {
                print("data response failed")
                return
            }
            
            let dict = value as! [String: Any]
            
            guard let book: Book = try? unbox(dictionary: dict) else {
                print("unboxing failed")
                return
            }
            
            print(book)
            completion(book)
        }
    }
}
