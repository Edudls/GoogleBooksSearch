//
//  ViewController.swift
//  BookSearch
//
//  Created by DMonaghan on 1/10/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var books: [Book] = []
    let service = NetworkService()
    let realm = RealmService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupViewController()
    }
    
    func setupViewController() {
        searchBar.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let cellNib = UINib(nibName: "BookCollectionViewCell", bundle: nil)
        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "bookCell")
    }
    
    //MARK: Double tap action handling
    @IBAction func doubleTapCellHandler(_ sender: UITapGestureRecognizer) {
        
        //find the point/cell in the collecion view that was double tapped
        let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
        guard let indexPath: IndexPath = self.collectionView.indexPathForItem(at: pointInCollectionView) else {return}
        
        //display or hide the "favorited" heart icon
        self.books[indexPath.row].isFavorite.toggle()
        
        //get the book we're working with
        let book = self.books[indexPath.row]
        if book.isFavorite == true {
            //save the book if it's being favorited (realm automatically overwrites duplicates with the same ID)
            realm.save(book: book)
            //print("saved " + book.title)
        } else {
            //delete the book from if it's being unfavorited
            realm.remove(book: book)
            //print("deleted " + book.title)
        }
        
        //print("booped " + String(indexPath.row) + " " + String(self.books[indexPath.row].isFavorite))
        self.collectionView.reloadData()
    }
    
}

extension ViewController: UISearchBarDelegate {
    //search bar delegate setup is necessary for the search bar to pass the text as data
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //get the query text after search is hit
        guard let query = searchBar.text else {return}
        
        //cosmetic changes
        self.title = "Search for \"" + query + "\""
        self.view.endEditing(true)
        
        //get the books from the api that match the query
        service.search(for: query) { book in
            self.books = book
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //dismiss the keyboard if cancel is hit
        self.view.endEditing(true)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    //basic setup
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCollectionViewCell
        
        let book = books[indexPath.row]
        
        cell.configure(with: book)
        cell.favIcon.isHidden = !book.isFavorite
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = self.collectionView.frame.size.width
        
        return CGSize(width: screenWidth/3.0, height: 220)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
