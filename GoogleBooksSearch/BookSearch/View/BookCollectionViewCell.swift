//
//  BookCollectionViewCell.swift
//  BookSearch
//
//  Created by DMonaghan on 1/14/19.
//  Copyright © 2019 DMonaghan. All rights reserved.
//

import UIKit
import SDWebImage

class BookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var authorText: UILabel!
    @IBOutlet weak var favIcon: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    let defaultImage = Bundle.main.path(forResource: "notFound", ofType: "png")!
    let heartImage = Bundle.main.path(forResource: "heart", ofType: "png")!
    
    func configure(with book: Book) {
        
        self.titleText.text = book.title
        
        //gotta convert the array of strings from authors into a single string to display
        if let authors = book.authors {
            var text = ""
            for author in authors {
                text.append(author + ", ")
            }
            text.removeLast()
            text.removeLast()
            self.authorText.text = text
        } else {self.authorText.text = "Author unknown"}
        
        //get the thumbnail (if it exists) using the thumbnail url
        if let urlText = book.thumbnail {
            //replace "http" with "https" so it's a secure web request
            let url = URL(string: urlText.replacingOccurrences(of: "http", with: "https"))
            self.imageView.sd_setImage(with: url, placeholderImage: nil)
        } else { self.imageView.image = UIImage(contentsOfFile: self.defaultImage) }
        
        self.favIcon.image = UIImage(contentsOfFile: self.heartImage)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
}
