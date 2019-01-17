//
//  FavoritesViewController.swift
//  BookSearch
//
//  Created by DMonaghan on 1/15/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    
    var favBooks: [Book] = []
    let realm = RealmService()
    let service = NetworkService()
    var alertHandler: (UIAlertAction) -> () = {_ in return}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFavoritesViewController()
    }
    
    func setupFavoritesViewController() {
        
        self.loadBooks()
        
        self.favoritesCollectionView.dataSource = self
        self.favoritesCollectionView.delegate = self
        
        let cellNib = UINib(nibName: "BookCollectionViewCell", bundle: nil)
        self.favoritesCollectionView.register(cellNib, forCellWithReuseIdentifier: "bookCell")
    }
    
    func loadBooks() {
        self.favBooks = []
        
        realm.getBooks() { bookIDs in
            for id in bookIDs {
                self.service.getBook(with: id) { book in
                    self.favBooks.append(book)
                    self.favoritesCollectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        self.loadBooks()
    }
    
    @IBAction func doubleTapCellHandler(_ sender: UITapGestureRecognizer) {
        let pointInCollectionView: CGPoint = sender.location(in: self.favoritesCollectionView)
        guard let indexPath: IndexPath = self.favoritesCollectionView.indexPathForItem(at: pointInCollectionView) else {return}
        
        alertHandler = { _ in
            self.realm.remove(book: self.favBooks[indexPath.row])
            self.favBooks.remove(at: indexPath.row)
            self.favoritesCollectionView.deleteItems(at: [indexPath])
            //print("booped " + String(indexPath.row) + " " + String(self.favBooks[indexPath.row].isFavorite))
            //self.favoritesCollectionView.reloadData()
        }
        
        let deleteAlert = UIAlertController(title: "Unfavorite Book", message: "Delete this book from your favorites?", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in return}))
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCollectionViewCell
        
        let book = favBooks[indexPath.row]
        
        cell.configure(with: book)
        //cell.favIcon.isHidden = !book.isFavorite
        
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = self.favoritesCollectionView.frame.size.width
        
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
