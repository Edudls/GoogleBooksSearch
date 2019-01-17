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
    let favorites = FavoritesViewController()
    
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
    
    @IBAction func doubleTapCellHandler(_ sender: UITapGestureRecognizer) {
        
        let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
        guard let indexPath: IndexPath = self.collectionView.indexPathForItem(at: pointInCollectionView) else {return}
        
        self.books[indexPath.row].isFavorite.toggle()
        
        let book = self.books[indexPath.row]
        if book.isFavorite == true {
            realm.save(book: book)
            print("saved " + book.title)
            favorites.favBooks.append(book)
        } else {
            realm.remove(book: book)
            print("deleted " + book.title)
            favorites.favBooks.removeAll { $0.identifier == book.identifier }
        }
        
        //print("booped " + String(indexPath.row) + " " + String(self.books[indexPath.row].isFavorite))
        self.collectionView.reloadData()
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let query = searchBar.text else {return}
        
        self.title = "Search for \"" + query + "\""
        self.view.endEditing(true)
        
        service.search(for: query) { book in
            self.books = book
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}

extension ViewController: UICollectionViewDataSource {
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
