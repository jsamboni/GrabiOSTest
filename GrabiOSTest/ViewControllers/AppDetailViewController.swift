//
//  AppDetailViewController.swift
//  GrabiOSTest
//
//  Created by Juan Carlos Samboní Ramírez on 4/06/16.
//
//

import UIKit

class AppDetailViewController: UIViewController {

    @IBOutlet weak var imageView: AsyncImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    
    var appInfo: App!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        summaryTextView.setContentOffset(CGPointZero, animated: true)
        if kIsIpad {
            let recognizer = UITapGestureRecognizer(target: self, action: Selector("handleTapBehind:"))
            recognizer.numberOfTapsRequired = 1
            recognizer.cancelsTouchesInView = false
            view.window?.addGestureRecognizer(recognizer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureUI() {
        navigationItem.title = appInfo.name
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.grabFontSourceSansProRegular(17)]
        nameLabel.font = UIFont.grabFontSourceSansProRegular(17)
        artistLabel.font = UIFont.grabFontSourceSansProRegular(15)
        priceLabel.font = UIFont.grabFontSourceSansProRegular(17)
        summaryTextView.font = UIFont.grabFontSourceSansProRegular(15)
        
        imageView.setImageWithURL(NSURL(string: appInfo.imageUrl)!)
        nameLabel.text = appInfo.name
        artistLabel.text = appInfo.artist
        let price = NSNumber(float: appInfo.price)
        if price == 0.0{
            priceLabel.text = "Free"
        }else{
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            let priceString = formatter.stringFromNumber(price)!
            priceLabel.text = "\(appInfo.currency) \(priceString)"
        }
        summaryTextView.text = appInfo.description
        
        imageView.layer.cornerRadius = imageView.frame.size.width/8.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        imageView.clipsToBounds = true
        
        view.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        view.layer.shadowOpacity = 1.0;
        view.layer.shadowRadius = 2.0;
        view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        view.clipsToBounds = false
    }
    
    func handleTapBehind(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended{
            var location:CGPoint = sender.locationInView(nil)
            if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("8.0"){
                location = CGPointMake(location.y, location.x)
            }
            if !view.pointInside(view.convertPoint(location, fromView: view.window), withEvent: nil){
                view.window?.removeGestureRecognizer(sender)
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.currentDevice().systemVersion.compare(version,
                                                              options: NSStringCompareOptions.NumericSearch) != NSComparisonResult.OrderedAscending
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
