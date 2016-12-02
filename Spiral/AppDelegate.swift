//
//  AppDelegate.swift
//  Spiral
//
//  Created by Guanqing Yan on 5/15/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

import UIKit
import GameKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    internal var achievementsDictionary = [String:GKAchievement]()
    internal var gameCenterEnabled = false
    internal var leaderboardIdentifier:String?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIPageControl.appearance().backgroundColor = UIColor.clearColor()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        let localPlayer = GKLocalPlayer.localPlayer()
            localPlayer.authenticateHandler = {(viewController : UIViewController?, error : NSError?) -> Void in
                if (viewController != nil){
                    self.window?.rootViewController?.presentViewController(viewController!, animated: true, completion: nil)
                }else{
                    if (localPlayer.authenticated){
                        self.gameCenterEnabled = true
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticationChanged", name: GKPlayerAuthenticationDidChangeNotificationName, object: nil)
                        localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (identifier:String?, error2:NSError?) -> Void in
                            if (error2 != nil){
                                print(error2!.localizedDescription)
                            }else {
                                self.leaderboardIdentifier = identifier
                            }
                        })
                        self.loadAchievements()
                    }else{
                        self.gameCenterEnabled = false
                    }
                }
        }
        let b: AnyObject? = NSUserDefaults.standardUserDefaults().valueForKey("initialized")
        if(b == nil){
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: "initialized")
            NSUserDefaults.standardUserDefaults().setValue(0, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().setValue(0, forKey: "game")
            NSUserDefaults.standardUserDefaults().setValue(0, forKey: "perfect")
            NSUserDefaults.standardUserDefaults().setValue(false, forKey: "noAdPurchased")
            
            let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
            let mySettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
            
        }
        
//        //println(NSUserDefaults.standardUserDefaults().valueForKey("noAdPurchased"))
//        
//        var set = Set<String>()
//        set.insert("com.liketheair.spiral.noad")
//        let productRequest = SKProductsRequest(productIdentifiers: set)
//        productRequest.delegate = self as SK
//        productRequest.start()
        return true
    }
//    
//    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
//        print("product request did receive response")
//        if (response.products.count != 1){
//            print("received more than one product from query")
//            return
//        }
//        self.noAdProduct = response.products[0] as? SKProduct
//    }
//    func request(request: SKRequest, didFailWithError error: NSError) {
//        
//        print(error.localizedDescription)
//    }
//    
//    internal func buyNoAd(){
//        
//        let a = NSUserDefaults.standardUserDefaults().boolForKey("noAdPurchased")
//        if (!a){
//            if(SKPaymentQueue.canMakePayments()){
//                if(self.noAdProduct==nil){
//                    var alert = UIAlertView(title: "Unable to purchase", message: "The purchase cannot be made at this time. Please try again later.", delegate: nil, cancelButtonTitle: "Fine")
//                    self.showAlert(alert)
//                    return
//                }
//                let payment = SKPayment(product: self.noAdProduct)
//                SKPaymentQueue.defaultQueue().addTransactionObserver(self)
//                SKPaymentQueue.defaultQueue().addPayment(payment)
//            }else{
//                var alert = UIAlertView(title: "Cannot Purchase", message: "The requested purchase is not allowed.", delegate: nil, cancelButtonTitle: "Fine")
//                self.showAlert(alert)
//            }
//        }
//        else{
//            var alert = UIAlertView(title: "Already Purchased", message: "You have purchased this item before.", delegate: nil, cancelButtonTitle: "OK")
//            self.showAlert(alert)
//        }
//    }
//    
//    internal func restoreNoAd(){
//        let a = NSUserDefaults.standardUserDefaults().boolForKey("noAdPurchased")
//        if (!a){
//            if(self.noAdProduct==nil){
//                var alert = UIAlertView(title: "Unable to purchase", message: "The purchase cannot be made at this time. Please try again later.", delegate: nil, cancelButtonTitle: "Fine")
//                self.showAlert(alert)
//                return
//            }
//                let payment = SKPayment(product: self.noAdProduct)
//                SKPaymentQueue.defaultQueue().addTransactionObserver(self)
//                SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
//        }
//        else{
//            var alert = UIAlertView(title: "Already Effective", message: "Ads are already removed.", delegate: nil, cancelButtonTitle: "OK")
//            self.showAlert(alert)
//        }
//    }
//    
//    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions{
//            switch((transaction ).transactionState){
//            case SKPaymentTransactionState.Purchased:
//                let alert = UIAlertView(title: "Purchase Success", message: "The advertisements will now be removed.", delegate: nil, cancelButtonTitle: "OK")
//                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "noAdPurchased")
//                NSNotificationCenter.defaultCenter().postNotificationName("noAdPurchased", object: nil)
//                self.showAlert(alert)
//                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
//            case SKPaymentTransactionState.Failed:
//                let alert = UIAlertView(title: "Purchase Failed", message: "The transaction failed. Please try again later.", delegate: nil, cancelButtonTitle: "OK")
//                self.showAlert(alert)
//                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
//            case SKPaymentTransactionState.Restored:
//                let alert = UIAlertView(title: "Purchase Restored", message: "You have purchased this item before. Now it is restored.", delegate: nil, cancelButtonTitle: "OK")
//                NSNotificationCenter.defaultCenter().postNotificationName("noAdPurchased", object: nil)
//                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "noAdPurchased")
//                self.showAlert(alert)
//                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
//            default:
//                let alert = UIAlertView(title: "Payment Processing", message: "The purchase is under processing", delegate: nil, cancelButtonTitle: "OK")
//                self.showAlert(alert)
//            }
//        }
//    }
//    
//    func showAlert(alert:UIAlertView){
//        let vc = self.window?.rootViewController as! ViewController
//        let end = vc.endGamePopUpVC
//        end?.showAlert(alert)
//    }
    
    func authenticationChanged(){
        self.gameCenterEnabled = GKLocalPlayer.localPlayer().authenticated
    }
    
    func loadAchievements(){
        GKAchievement.loadAchievementsWithCompletionHandler { (achievements:[GKAchievement]?, error:NSError?) -> Void in
            if(error == nil){
                for a in achievements! {
                    self.achievementsDictionary[a.identifier!] = a
                }
            }
            //self.resetAchievements()
        }
    }
    
    func resetAchievements(){
        self.achievementsDictionary.removeAll(keepCapacity: false)
        GKAchievement.resetAchievementsWithCompletionHandler { (error:NSError?) -> Void in
            if (error != nil){
                print(error!.localizedDescription)
            }
        }
    }
    
    func achievementForIdentifier(identifier:String)->GKAchievement{
        var a = self.achievementsDictionary[identifier]
        if (a == nil){
            a = GKAchievement(identifier: identifier)
            self.achievementsDictionary[identifier] = a
        }
        return a!
    }
    
    internal func reportScore(score:Int,perfect:Int,game:Int){
        self.reportGame(game)
        self.reportScore(score)
        self.reportPerfect(perfect)
        
        var p = NSUserDefaults.standardUserDefaults().valueForKey("perfect")!.unsignedIntegerValue!
        var g = NSUserDefaults.standardUserDefaults().valueForKey("game")!.unsignedIntegerValue!
        
        var report = [GKAchievement]();
        //scores
        var temp = self.achievementForIdentifier("com.liketheair.spiral.point10")
        if (temp.percentComplete != 100 && score >= 10){
            temp.percentComplete = 100
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.point50")
        if (temp.percentComplete != 100 && score >= 50){
            temp.percentComplete = 100
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.point200")
        if (temp.percentComplete != 100 && score >= 200){
            temp.percentComplete = 100
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.point500")
        if (temp.percentComplete != 100 && score >= 500){
            temp.percentComplete = 100
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.point1500")
        if (temp.percentComplete != 100 && score >= 1500){
            temp.percentComplete = 100
            report.append(temp)
        }
        //perfects
        if (perfect != 0){
            temp = self.achievementForIdentifier("com.liketheair.spiral.perfect1")
            var tempNum = temp.percentComplete
            var tempNum2 = 0.0
            if (tempNum < 100){
                tempNum = p >= 1 ? 100 : Double(p)
                temp.percentComplete = Double(tempNum)
                report.append(temp)
            }
            
            temp = self.achievementForIdentifier("com.liketheair.spiral.perfect5")
            tempNum = temp.percentComplete
            if (tempNum < 100){
                tempNum = p >= 5 ? 100 : Double(p)  * 20
                temp.percentComplete = Double(tempNum)
                report.append(temp)
            }
            temp = self.achievementForIdentifier("com.liketheair.spiral.perfect25")
            tempNum = temp.percentComplete
            if (tempNum < 100){
                tempNum = p >= 25 ? 100 : Double(p) * 4
                temp.percentComplete = Double(tempNum)
                report.append(temp)
            }
            temp = self.achievementForIdentifier("com.liketheair.spiral.perfect100")
            tempNum = temp.percentComplete
            if (tempNum < 100){
                tempNum = p >= 125 ? 100 : Double(p)
                temp.percentComplete = Double(tempNum)
                report.append(temp)
            }
            temp = self.achievementForIdentifier("com.liketheair.spiral.perfect500")
            tempNum = temp.percentComplete
            if (tempNum < 100){
                tempNum = p >= 500 ? 100 : Double(p) * 0.2
                temp.percentComplete = Double(tempNum)
                report.append(temp)
            }
        }
        
        //games
        var tempNum = 0.0
        var tempNum2 = 0.0
        temp = self.achievementForIdentifier("com.liketheair.spiral.game1")
        tempNum = temp.percentComplete
        if (tempNum < 100){
            tempNum = p >= 1 ? 100 : Double(g)
            temp.percentComplete = Double(tempNum)
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.game5")
        tempNum = temp.percentComplete
        if (tempNum < 100){
            tempNum = p >= 5 ? 100 : Double(g) * 20
            temp.percentComplete = Double(tempNum)
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.game20")
        tempNum = temp.percentComplete
        if (tempNum < 100){
            tempNum = p >= 20 ? 100 : Double(g) * 5
            temp.percentComplete = Double(tempNum)
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.game100")
        tempNum = temp.percentComplete
        if (tempNum < 100){
            tempNum = p >= 100 ? 100 : Double(g)
            temp.percentComplete = Double(tempNum)
            report.append(temp)
        }
        temp = self.achievementForIdentifier("com.liketheair.spiral.game500")
        tempNum = temp.percentComplete
        if (tempNum < 100){
            tempNum = p >= 500 ? 100 : Double(g) * 0.2
            temp.percentComplete = Double(tempNum)
            report.append(temp)
        }
        if (report.count > 1){
            for a in report{
                a.showsCompletionBanner = true
            }
            GKAchievement.reportAchievements(report, withCompletionHandler: { (error:NSError?) -> Void in
                if (error != nil){
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    func reportScore(hscore:Int){
        let score  = GKScore(leaderboardIdentifier: "com.liketheair.spiral.bestScoreLeaderboard")
        score.value = Int64(hscore)
        GKScore.reportScores([score], withCompletionHandler: { (error:NSError?) -> Void in
            if (error != nil){
                print(error!.localizedDescription)
            }
        })
    }
    func reportPerfect(perfect:Int){
        let score  = GKScore(leaderboardIdentifier: "com.liketheair.spiral.perfectCount")
        score.value = Int64(perfect)
        GKScore.reportScores([score], withCompletionHandler: { (error:NSError?) -> Void in
            if (error != nil){
                print(error!.localizedDescription)
            }
        })
    }
    func reportGame(game:Int){
        let score  = GKScore(leaderboardIdentifier: "com.liketheair.spiral.gamesPlayed")
        score.value = Int64(game)
        GKScore.reportScores([score], withCompletionHandler: { (error:NSError?) -> Void in
            if (error != nil){
                print(error!.localizedDescription)
            }
        })
    }
    
    func scheduleNotifications(times:Int){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
//        let types = UIApplication.sharedApplication().enabledRemoteNotificationTypes()
//        if (types & UIRemoteNotificationType.Alert)
//        {
//            
//        }
//        else if (types & UIRemoteNotificationType.Sound)
//        {
//            
//        }
        let type = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
        if (type == UIUserNotificationType()){
            return
        }
        
        let calendar = NSCalendar.autoupdatingCurrentCalendar()
        let datecomps = NSDateComponents()
        var cur = NSDate()
        for i in 1...times {
            cur = calendar.dateByAddingUnit(NSCalendarUnit.Hour, value: 24, toDate: cur, options: NSCalendarOptions())!
            let not = UILocalNotification()
            not.fireDate = cur
            not.timeZone = NSTimeZone.defaultTimeZone()
            not.alertBody = "Come back and challenge yourself!"
            not.alertAction  = "Play"
            if ((type.rawValue & UIUserNotificationType.Sound.rawValue) != 0){
                not.soundName = UILocalNotificationDefaultSoundName
            }
            not.applicationIconBadgeNumber = 1
            UIApplication.sharedApplication().scheduleLocalNotification(not)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.scheduleNotifications(10)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

