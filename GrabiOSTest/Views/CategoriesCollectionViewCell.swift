//
//  CategoriesiPhoneCollectionViewCell.swift
//  GrabiOSTest
//
//  Created by Juan Carlos Samboní Ramírez on 3/06/16.
//
//

import UIKit

class CategoriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = imageView.frame.size.width/2.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        imageView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let container: UIView! = contentView.viewWithTag(10)
        container.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        container.layer.shadowOpacity = 1.0;
        container.layer.shadowRadius = 2.0;
        container.layer.shadowColor = UIColor.lightGrayColor().CGColor
        
        
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.font = UIFont.grabFontSourceSansProRegular(14)
        
    }
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    func configureCell(category: Category){
        textLabel.text = category.name
        if let imageURL = category.imageUrl {
            imageView.setImageWithURL(NSURL(string: imageURL)!)
        }
    }
    
    override var highlighted: Bool{
        didSet {
            if self.highlighted {
                contentView.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }else{
                contentView.transform = CGAffineTransformIdentity
            }
        }
    }
}
