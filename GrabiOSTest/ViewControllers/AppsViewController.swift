//
//  AppsViewController.swift
//  GrabiOSTest
//
//  Created by Juan Carlos Samboní Ramírez on 4/06/16.
//
//

import UIKit
import VCTransitionsLibrary
import RZTransitions

class AppsViewController: UIViewController {
    var array_apps = [App]()
    var filter: String!
    var containerDetail: UIView!
    var startPoint: CGRect!
    @IBOutlet weak var collectionView_apps: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = filter
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.grabFontSourceSansProRegular(17)]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        collectionView_apps.delaysContentTouches = false
        
        parseJSONObject()
    }
    
    func parseJSONObject () -> Bool{
        let json = NSUserDefaults.standardUserDefaults().objectForKey("json_apple") as! [String: AnyObject]
        guard let feed = json["feed"] as? [String: AnyObject], let apps = feed["entry"] as? [[String: AnyObject]]
            else{
                //paila
                let alert = UIAlertController(title: "TopApps", message: "The requested information is not valid.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { [unowned self](action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                self.presentViewController(alert, animated: true, completion: nil)
                return false
        }
        
        for app: [String: AnyObject] in apps {
            guard let category = app["category"] as? [String: AnyObject], let attributes = category["attributes"] as? [String: AnyObject], let term = attributes["term"] as? String where term == filter
                else{
                    continue
            }
            guard let name = app["im:name"]!["label"] as? String, let description = app["summary"]!["label"] as? String
                else {
                    continue
            }
            guard let imageArray = app["im:image"] as? [AnyObject], let imageInfo = imageArray[0] as? [String: AnyObject], let imageUrl = imageInfo["label"] as? String
                else{
                    continue
            }
            guard let price = app["im:price"]!["attributes"]!!["amount"] as? String, let currency = app["im:price"]!["attributes"]!!["currency"] as? String
                else{
                    continue
            }
            guard let artist = app["im:artist"]!["label"] as? String
                else {
                    continue
            }
            
            let application = App()
            application.name = name
            application.imageUrl = imageUrl
            application.description = description
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .DecimalStyle
            if let number: NSNumber? = formatter.numberFromString(price)! as NSNumber {
                application.price = number!.floatValue
            }
            application.currency = currency
            application.artist = artist
            array_apps.append(application)
        }
        if array_apps.count == 0 {
            let alert = UIAlertController(title: "TopApps", message: "The requested information is not valid.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { [unowned self](action) in
                self.dismissViewControllerAnimated(true, completion: nil)
                }))
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = RZTransitionsManager.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destination = segue.destinationViewController as! AppDetailViewController
        destination.appInfo = array_apps[(sender as! NSIndexPath).row]
        if !kIsIpad{
            navigationController?.delegate = self
        }
        destination.transitioningDelegate = self;
        destination.modalPresentationStyle = .Custom;
    }
}

extension AppsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_apps.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if kIsIpad {
            return UIEdgeInsetsMake(30, 30, 30, 30)
        }
        return UIEdgeInsetsMake(16, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if kIsIpad {
            return 30
        }
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if kIsIpad {
            return CGSizeMake(280, 130)
        }else{
            return CGSizeMake(collectionView.bounds.width, 60)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: AppsCollectionViewCell! = collectionView.dequeueReusableCellWithReuseIdentifier(kIsIpad ? "CellPad" : "CellPhone", forIndexPath: indexPath) as! AppsCollectionViewCell
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cell.configureCell(array_apps[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if kIsIpad{
            startPoint = collectionView.convertRect(collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame, toView: view)
            performSegueWithIdentifier("SegueDetail", sender: indexPath)
        }else{
            performSegueWithIdentifier("SeguePushDetail", sender: indexPath)
        }
    }
}

extension AppsViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = CENatGeoAnimationController()
        animator.reverse = operation == .Pop;
        return animator
    }
}

extension AppsViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = Animator()
        animator.presenting = true
        animator.startPoint = startPoint
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = Animator()
        return animator
    }
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting:Bool = false
    var startPoint: CGRect!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController: UIViewController! = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController: UIViewController! = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let endFrame = CGRectMake(CGRectGetMidX(fromViewController.view.frame)-200, CGRectGetMidY(fromViewController.view.frame)-200, 400, 400);
        
        if (presenting) {
            fromViewController.view.userInteractionEnabled = false
            transitionContext.containerView()?.addSubview(toViewController.view)
            
            let startFrame = CGRectMake(startPoint.origin.x, startPoint.origin.y, 400, 400)
            
            toViewController.view.frame = startFrame;
            
            toViewController.view.transform = CGAffineTransformMakeScale(0, 0)
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                fromViewController.view.tintAdjustmentMode = .Dimmed
                toViewController.view.transform = CGAffineTransformIdentity
                toViewController.view.frame = endFrame;
                }, completion: { (finished) in
                    transitionContext.completeTransition(true)
            })
        }else {
            toViewController.view.userInteractionEnabled = true
            transitionContext.containerView()?.addSubview(fromViewController.view)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                toViewController.view.tintAdjustmentMode = .Automatic
                fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
                fromViewController.view.alpha = 0.0
                }, completion: { (finished) in
                    transitionContext.completeTransition(true)
            })
        }
    }
}
