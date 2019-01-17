//
//  FavoritesViewController.swift
//  BookSearch
//
//  Created by DMonaghan on 1/15/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

//MARK: Notes
//it occurs to me that I could clean up a lot of this code very easily by simply using static variables instead of frequently reloading my favorites page as I am doing to keep it up to date. I will probably rework this in this way if I get the time to revisit it.

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //gets called every time the tab bar is used to switch over to the favorites view
        loadBooks()
    }
    
    func setupFavoritesViewController() {
        //normal setup things
        self.favoritesCollectionView.dataSource = self
        self.favoritesCollectionView.delegate = self
        
        let cellNib = UINib(nibName: "BookCollectionViewCell", bundle: nil)
        self.favoritesCollectionView.register(cellNib, forCellWithReuseIdentifier: "bookCell")
    }
    
    func loadBooks() {
        //reload everything from the Realm and redownload the book info
        favBooks = []
        //MARK: This is honestly the worst code I have done in this entire project because of how many things get piled onto the DispatchQueue all at once, every time I open the window.
        realm.getBooks() { bookIDs in
            for id in bookIDs {
                self.service.getBook(with: id) { book in
                    self.favBooks.append(book)
                    self.favoritesCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Buttons/action handlers
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        self.loadBooks()
    }
    
    @IBAction func doubleTapCellHandler(_ sender: UITapGestureRecognizer) {
        //receives the double-tap in the collection view and finds the cell (if any) that was tapped
        let pointInCollectionView: CGPoint = sender.location(in: self.favoritesCollectionView)
        guard let indexPath: IndexPath = self.favoritesCollectionView.indexPathForItem(at: pointInCollectionView) else {return}
        //print("booped cell " + String(indexPath.row))
        
        //creates the handler for the alert action that'll delete the favorite if you hit "OK"
        alertHandler = { _ in
            self.realm.remove(book: self.favBooks[indexPath.row])
            self.favBooks.remove(at: indexPath.row)
            self.favoritesCollectionView.deleteItems(at: [indexPath])
        }
        
        //build the alert (yes, you have to do this every time this gets called for it to display right)
        let deleteAlert = UIAlertController(title: "Unfavorite Book", message: "Delete this book from your favorites?", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in return}))
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: alertHandler))
        
        //present the alert to give the "are you sure?" message
        self.present(deleteAlert, animated: true, completion: nil)
    }
}

//MARK: Collection View Setup
extension FavoritesViewController: UICollectionViewDataSource {
    //almost exactly the same as on the other view controller
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! BookCollectionViewCell
        
        let book = favBooks[indexPath.row]
        
        cell.configure(with: book)
        
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
