//
//  AppsCollectionViewCell.swift
//  GrabiOSTest
//
//  Created by Juan Carlos Samboní Ramírez on 4/06/16.
//
//

import UIKit

class AppsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
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
        
        priceLabel.adjustsFontSizeToFitWidth = true
        
        if kIsIpad {
            artistLabel.adjustsFontSizeToFitWidth = true
            artistLabel.font = UIFont.grabFontSourceSansProRegular(14)
            
            priceLabel.font = UIFont.grabFontSourceSansProRegular(14)
            textLabel.font = UIFont.grabFontSourceSansProRegular(16)
        }else{
            textLabel.font = UIFont.grabFontSourceSansProRegular(14)
            priceLabel.font = UIFont.grabFontSourceSansProRegular(12)
        }
        
    }
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    func configureCell(app: App){
        textLabel.text = app.name
        imageView.setImageWithURL(NSURL(string: app.imageUrl)!)
        let price = NSNumber(float: app.price)
        if price == 0.0{
            priceLabel.text = "Free"
        }else{
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            let priceString = formatter.stringFromNumber(price)!
            priceLabel.text = "\(app.currency) \(priceString)"
        }
        
        if kIsIpad {
            artistLabel.text = app.artist
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
