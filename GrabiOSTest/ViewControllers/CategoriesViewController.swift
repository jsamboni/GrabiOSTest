//
//  ViewController.swift
//  GrabiOSTest
//
//  Created by Juan Carlos Samboní Ramírez on 3/06/16.
//
//

import UIKit
import AFNetworking
import RZTransitions

let kIsIpad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
let jsonURL = "https://itunes.apple.com/us/rss/topfreeapplications/limit=20/json"

class CategoriesViewController: UIViewController {

    @IBOutlet weak var collectionView_categories: UICollectionView!
    
    var array_categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        RZTransitionsManager.shared().setAnimationController( RZZoomBlurAnimationController(),
                                                              fromViewController:self.dynamicType,
                                                              toViewController:AppsViewController.self,
                                                              forAction:.PushPop)
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.grabFontSourceSansProRegular(17)]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        collectionView_categories.delaysContentTouches = false
        
        setReachabilityStatusManager()
        downloadInfo()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = RZTransitionsManager.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setReachabilityStatusManager() {
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { [unowned self](status:AFNetworkReachabilityStatus) in
            print("Reachability: \(AFStringFromNetworkReachabilityStatus(status))")
            switch status {
            case .NotReachable:
                if NSUserDefaults.standardUserDefaults().objectForKey("json_apple") != nil{
                    JLToast.makeText("Looks like you have no Internet connection.\nYou're now in Offline Mode.", duration: 5).show()
                }else{
                    let alert = UIAlertController(title: "TopApps", message: "Looks like you have no Internet connection.\nInformation couldn't be downloaded", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Got it!", style: .Default, handler: { [unowned self](action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            case .ReachableViaWiFi:
                if self.array_categories.count == 0{
                    self.downloadInfo()
                }
                break
            case .ReachableViaWWAN:
                break
            case .Unknown:
                JLToast.makeText("Looks like you have no Internet connection.\nYou're now in Offline Mode.", duration: 5).show()
            }
        }
    }
    
    func downloadInfo (){
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manager = AFHTTPSessionManager(sessionConfiguration: configuration)
        
        manager.GET(jsonURL, parameters: nil, progress: nil, success: { [unowned self](task: NSURLSessionDataTask, response) in
            //print("response: \(response!)")
            let json = response as! [String: AnyObject]
            NSUserDefaults.standardUserDefaults().setObject(json, forKey: "json_apple")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            self.parseJSONObject(json)
            AFNetworkReachabilityManager.sharedManager().startMonitoring()
        }) { (operation: NSURLSessionDataTask?, error) in
            print("error")
            if let json = NSUserDefaults.standardUserDefaults().objectForKey("json_apple") as? [String: AnyObject] {
                self.parseJSONObject(json)
            }
            AFNetworkReachabilityManager.sharedManager().startMonitoring()
        }
    }
    
    func parseJSONObject(json:[String: AnyObject]) -> Bool{
        guard let feed = json["feed"] as? [String: AnyObject], let apps = feed["entry"] as? [[String: AnyObject]]
            else{
                //paila
                let alert = UIAlertController(title: "TopApps", message: "The downloaded information appears to be invalid.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { [unowned self](action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                self.presentViewController(alert, animated: true, completion: nil)
                return false
        }
        
        for app: [String: AnyObject] in apps {
            guard let category = app["category"] as? [String: AnyObject], let attributes = category["attributes"] as? [String: AnyObject], let term = attributes["term"] as? String
                else{
                    //intentar con el siguiente dato
                    continue
            }
            if !self.array_categories.contains( {$0.name == term} ){
                guard let imageArray = app["im:image"] as? [AnyObject], let imageInfo = imageArray[0] as? [String: AnyObject], let label = imageInfo["label"] as? String
                    else{
                        let category = Category()
                        category.name = term
                        category.imageUrl = ""
                        self.array_categories.append(category)
                        continue
                }
                let category = Category()
                category.name = term
                category.imageUrl = label
                self.array_categories.append(category)
            }
        }
        self.collectionView_categories.reloadSections(NSIndexSet(index: 0))
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! AppsViewController
        destination.filter = array_categories[(sender as! NSIndexPath).row].name
    }
}

extension CategoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array_categories.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if kIsIpad {
            return UIEdgeInsetsMake(30, 30, 30, 30)
        }
        return UIEdgeInsetsMake(16, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if kIsIpad {
            return 50
        }
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if kIsIpad {
            return CGSizeMake(168, 168)
        }else{
            return CGSizeMake(collectionView.bounds.width, 60)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CategoriesCollectionViewCell! = collectionView.dequeueReusableCellWithReuseIdentifier(kIsIpad ? "CellPad" : "CellPhone", forIndexPath: indexPath) as! CategoriesCollectionViewCell
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cell.configureCell(array_categories[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("SegueApps", sender: indexPath)
    }
}

