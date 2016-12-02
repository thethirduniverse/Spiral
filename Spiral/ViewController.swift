//
//  ViewController.swift
//  Spiral
//
//  Created by Guanqing Yan on 5/15/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

import UIKit
import GameKit
import iAd
import StoreKit
import AVFoundation

enum passType{
    case perfect
    case good
    case barely
}

enum failType{
    //case timeOut
    case bad
}

class ViewController: UIViewController,endGamePopUpProtocol,TutorialViewControllerDelegate,GKGameCenterControllerDelegate, ADBannerViewDelegate,ADInterstitialAdDelegate{
    @IBOutlet weak var spiralLabel: SpringLabel!
    @IBOutlet weak var startButton: SpringButton!
    @IBOutlet weak var rankButton: SpringButton!
    @IBOutlet weak var spiral: SpringButton!
    @IBOutlet weak var newsLabel: SpringLabel!
    @IBOutlet weak var objectiveLabel: SpringLabel!
    var endGamePopUp: SpringView?
    var showingEndGamePopUp = false
    internal var endGamePopUpVC: endGamePopUpViewController?
    var objective:Double = 0.0
    var differnce:Double = 0.0
    var spinning = false
    var timeoutTimer:NSTimer?
    var startTime:NSDate?
    var currentScore:Int = 0 {
        didSet{
            self.spiralLabel.text = "\(currentScore)"
        }
    }
    var currentPerfect:Int = 0
    var highscore = false;
    var newsForPopUpView:String?
    var perfectBonus = 0
    
//    var showAdCount = 5
//    var interstitialAd:ADInterstitialAd?
//    var ads = true
//    
//    @IBOutlet weak var noadConstraint: NSLayoutConstraint!
    
    
    var player = SoundPlayer();
//    var passSound:AVAudioPlayer?
//    var failSound:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objectiveLabel.layer.cornerRadius = 10
        self.rankButton.layer.borderWidth = 5
        self.startButton.layer.borderWidth = 5
        
        spiralLabel.animation = "squeezeDown"
        startButton.animation = "squeezeUp"
        rankButton.animation = "squeezeUp"
        spiral.animation = "squeezeDown"
        
        spiral.delay = 0.2
        
        spiralLabel.animate()
        startButton.animate()
        rankButton.animate()
        spiral.animateNext { () -> () in
            self.startSpinning();
        }
//        
//        self.view.removeConstraint(self.noadConstraint)
//        if (NSUserDefaults.standardUserDefaults().boolForKey("noAdPurchased")){
//            self.removeAds()
//        }else{
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPurchaseNoAd:", name: "noAdPurchased", object: nil)
//        }
        
//        let path1 = NSBundle.mainBundle().pathForResource("fail", ofType: "wav")
//        let path2 = NSBundle.mainBundle().pathForResource("pass", ofType: "wav")
//        
//        var error:NSError?
//        self.failSound =  AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(path1!), error: &error)
//        self.passSound =  AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(path2!), error: &error)
        
        /*
        AudioServicesCreateSystemSoundID(NSURL.fileURLWithPath(path1!) as! CFURLRef,&self.failSoundId);
        AudioServicesCreateSystemSoundID(NSURL.fileURLWithPath(path2!) as! CFURLRef,&self.failSoundId);
        
        if (path1 != nil && path2 != nil) {
            withUnsafePointers(&self.failSoundId, &self.passSoundId, { (ptr1: UnsafePointer, ptr2: UnsafePointer) -> Void in
                var voidPtr1: UnsafeMutablePointer = unsafeBitCast(ptr1, UnsafeMutablePointer<SystemSoundID>.self)
                var voidPtr2: UnsafeMutablePointer = unsafeBitCast(ptr2, UnsafeMutablePointer<SystemSoundID>.self)
                AudioServicesCreateSystemSoundID(NSURL.fileURLWithPath(path1!) as! CFURLRef,voidPtr1);
                AudioServicesCreateSystemSoundID(NSURL.fileURLWithPath(path2!) as! CFURLRef,voidPtr2);
            })
        }
        */
    }
    
    override func viewDidLayoutSubviews() {
        rankButton.layer.cornerRadius = rankButton.bounds.height/2
        startButton.layer.cornerRadius = startButton.bounds.height/2
    }
    
//    func didPurchaseNoAd(notifiation:NSNotification){
//        self.removeAds()
//        //NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: "noAdPurchased")
//    }
    
//    func removeAds(){
//        self.ads = false
////        var frame = self.adBanner.frame
////        frame.origin.y = frame.origin.y + frame.size.height
////        frame.size.height = 0
////        self.adBanner.frame = frame
////        self.adBanner.hidden = true
//        self.adBanner.removeFromSuperview()
//        self.view.addConstraint(self.noadConstraint)
//    }

    @IBAction func startButtonTapped(sender: SpringButton) {
        self.setPlayStage()
        if (!self.showTutorialIfNeeded()){
            self.startGame()
        }
    }
    
    func showTutorialIfNeeded()->Bool{
        if(!NSUserDefaults.standardUserDefaults().boolForKey("tutorialShowed")){
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "tutorialShowed")
            let tutorial = self.storyboard?.instantiateViewControllerWithIdentifier("tutorial") as! TutorialViewController
            self.providesPresentationContextTransitionStyle = true
            self.definesPresentationContext = true
            tutorial.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            tutorial.dismissDelegate = self
            self.presentViewController(tutorial, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    func dismissButtonTapped() {
        self.startGame()
    }
    
    @IBAction func rankButtonTapped(sender: SpringButton) {
        self.showLeaderboard()
    }
    
    func showLeaderboard(){
        let gvc = GKGameCenterViewController()
        gvc.viewState = GKGameCenterViewControllerState.Leaderboards
        gvc.gameCenterDelegate = self
        if(self.showingEndGamePopUp){
            self.endGamePopUpVC?.presentViewController(gvc, animated: true, completion: nil)
        }else{
            self.presentViewController(gvc, animated: true, completion: nil)
        }
    }
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        if(self.showingEndGamePopUp){
            self.endGamePopUpVC?.dismissViewControllerAnimated(true, completion: nil)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func showShareMenu(){
        let activityViewController = UIActivityViewController(activityItems:[String(format:"I have scored %d in Spiral. Challenge Me!", self.currentScore)], applicationActivities: nil)
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            self.providesPresentationContextTransitionStyle = true
            self.endGamePopUpVC!.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        case .OrderedAscending:
            self.endGamePopUpVC!.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            //need testing on ios7
        }
        self.endGamePopUpVC!.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func setPlayStage(){
        spiralLabel.animation = "fall"
        startButton.animation = "fall"
        rankButton.animation = "fall"
        spiralLabel.delay = 0.15
        rankButton.delay = 0.07;
        spiralLabel.animate()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.spiralLabel.alpha = 0.0
            }, completion: { (_) -> Void in
                self.spiralLabel.hidden = true
        })
        startButton.animateNext{
            self.startButton.hidden = true
        }
        rankButton.animateNext{
            self.rankButton.hidden = true
        }
    }
    
    func startGame(){
        self.showCountDown(true)
        self.currentScore = 0;
    }
    
    func restartGame(){
        self.showCountDown(false)
        self.gameWillRestart()
    }
    
    func continueGame(){
        self.showCountDown(false)
    }
    
    func gameWillRestart(){
        self.currentScore = 0;
        self.currentPerfect = 0;
    }
    
    func showCountDown(first:Bool){
        if (first){
            self.stopSpinning()
            newsLabel.hidden = false
            self.newsLabel.text = "3"
            newsLabel.animation = "slideRight"
            newsLabel.animateNext{
                self.newsLabel.animation = "zoomOut"
                self.newsLabel.animateNext{
                    self.newsLabel.text = "2"
                    self.newsLabel.animation = "slideRight"
                    self.newsLabel.animateNext{
                        self.newsLabel.animation = "zoomOut"
                        self.newsLabel.animateNext{
                            self.newsLabel.text = "1"
                            self.newsLabel.animation = "slideRight"
                            self.newsLabel.animateNext{
                                self.newsLabel.animation = "zoomOut"
                                self.newsLabel.animateNext{
                                    self.newsLabel.text = "Go"
                                    self.newsLabel.animation = "slideRight"
                                    self.newsLabel.animateNext{
                                        self.newsLabel.animation = "zoomOut"
                                        self.newsLabel.animateNext{
                                            self.startSpinning()
                                            self.showObjective()
                                            self.objectiveLabel.animation = "squeezeUp"
                                            self.objectiveLabel.animate()
                                            self.gameDidStart(first)
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                }
            }
        }else{
            self.stopSpinning()
            self.newsLabel.text = "Go"
            self.newsLabel.animation = "slideRight"
            self.newsLabel.animateNext{
                self.newsLabel.animation = "zoomOut"
                self.newsLabel.animateNext{
                    self.startSpinning()
                    self.showObjective()
                    self.objectiveLabel.animation = "pop"
                    self.objectiveLabel.animate()
                    self.gameDidStart(first)
                }
            }

        }
    }
    func showObjective(){
        objectiveLabel.hidden = false;
        objectiveLabel.text = String(format:"Goal: \(self.newObjective()) seconds")
    }
    
    func gameDidStart(first:Bool){
        self.spiral.userInteractionEnabled = true
        self.timeoutTimer = NSTimer(timeInterval: self.objective * 3/2, target: self, selector: "timeOut", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(self.timeoutTimer!, forMode: NSDefaultRunLoopMode)
        self.startTime = NSDate()
        if (first){
            self.spiral.userInteractionEnabled = true;
            self.spiralLabel.hidden = false;
            self.spiralLabel.animation = "squeezeDown"
            self.spiralLabel.animate()
        }
    }
    
    @IBAction func spiralTapped(sender: SpringButton) {
        self.calculateDifference()
    }
    
    func calculateDifference(){
        self.spiral.userInteractionEnabled = false
        let timePassed = NSDate().timeIntervalSinceDate(self.startTime!)
        self.differnce = timePassed - self.objective;
        let absDif = abs(differnce)
        let difPer = absDif / self.objective
        if (difPer < 1/16){
            self.passWithType(passType.perfect)
        }else if(difPer < 1/12){
            self.passWithType(passType.good)
        }else if(difPer < 1/8){
            self.passWithType(passType.barely)
        }else{
            self.failWithType(failType.bad)
        }
    }
    
    func passWithType(type: passType){
        //play sound
        //self.passSound?.play()
        self.player.playSound("pass.wav")
        self.timeoutTimer!.invalidate()
        self.timeoutTimer = nil
        switch(type){
        case passType.perfect:
            self.currentScore += 5
            if (self.perfectBonus != 0){
                self.newsLabel.numberOfLines = 2
                self.newsLabel.text = "Strike!\n+\(self.perfectBonus)"
                self.currentScore += self.perfectBonus
            } else {
                self.newsLabel.numberOfLines = 1
                self.newsLabel.text = "Perfect!"
            }
            perfectBonus++
            self.currentPerfect++
        case passType.good:
            perfectBonus = 0
            self.newsLabel.numberOfLines = 1
            self.newsLabel.text = "Good!"
            self.currentScore += 3
        case passType.barely:
            perfectBonus = 0
            self.newsLabel.numberOfLines = 1
            self.newsLabel.text = "Barely!"
            self.currentScore += 1
        }
        self.newsLabel.animation = "squeezeRight"
        self.newsLabel.animateNext{
            self.newsLabel.animation = "zoomOut"
            self.continueGame()
        }
    }
    
    func failWithType(type: failType){
        //play sound
        self.player.playSound("fail.wav")
        self.timeoutTimer!.invalidate()
        self.timeoutTimer = nil
        self.perfectBonus = 0
        if (NSUserDefaults.standardUserDefaults().valueForKey("highScore") == nil ||
            (NSUserDefaults.standardUserDefaults().valueForKey("highScore")?.unsignedIntegerValue < self.currentScore)){
            highscore = true;
            NSUserDefaults.standardUserDefaults().setValue(self.currentScore, forKey: "highScore")
            self.newsForPopUpView = "High Score!"
        }
        else{
            if (self.differnce < 0){
                self.newsForPopUpView = String(format:"You were %.1f seconds faster",abs(self.differnce))
            } else {
                self.newsForPopUpView = String(format:"You were %.1f seconds slower",abs(self.differnce))
            }
        }
        
        var p = NSUserDefaults.standardUserDefaults().valueForKey("perfect")!.unsignedIntegerValue!
        p += self.currentPerfect
        NSUserDefaults.standardUserDefaults().setValue(p, forKey: "perfect")
        var g = NSUserDefaults.standardUserDefaults().valueForKey("game")!.unsignedIntegerValue!
        g++
        NSUserDefaults.standardUserDefaults().setValue(g, forKey: "game")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.reportScore(self.currentScore, perfect: p, game: g)
        
        //hide objective
        self.objectiveLabel.animation = "faldeOut"
        self.objectiveLabel.animateNext{
            self.objectiveLabel.hidden = true
        }
        
        //show pop up
        self.showingEndGamePopUp = true
        let popUp = self.storyboard?.instantiateViewControllerWithIdentifier("endGame") as! endGamePopUpViewController
        self.endGamePopUpVC = popUp
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            self.providesPresentationContextTransitionStyle = true
            self.definesPresentationContext = true
            popUp.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        case .OrderedAscending:
            self.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            //need testing on ios7
        }
        self.presentViewController(popUp, animated: false) { () -> Void in
            //self.objectiveLabel.animation = "fall"
            popUp.delegate = self
            let sp = popUp.view as! SpringView
            sp.animation = "squeezeDown"
            sp.animate()
            self.endGamePopUp = sp
//            self.shouldShowAd = true
//            self.showAdIfNeedTo()
        }
        
        self.stopSpinning()
    }
    
    func timeOut(){
        self.calculateDifference()
    }
    
    func newObjective()->Double{
        //range is from 5 to 15, precision to one decimal point
        let rd = arc4random() % 50
        let time = Double(rd)/10 + 5
        self.objective = time
        return time
    }
    
    func startSpinning() {
        self.spinning = true;
        self.spin()
    }
    
    func stopSpinning() {
        self.spinning = false;
    }
    
    func spin() {
        let rd = arc4random() % 50
        let time = Double(rd)/500 + 0.1
        UIView.animateWithDuration(time, delay: 0.0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
            self.spiral.transform = CGAffineTransformRotate(self.spiral.transform, CGFloat(M_PI_4 / 2))
            }, completion:{ (_) -> Void in
                if(self.spinning){
                    self.spin()
                }
            })
     }
    
    func didPressShareButton(){
        self.showShareMenu()
    }
    
    func didPressReplayButton(){
        //        self.shouldShowAd = false
        self.endGamePopUp!.animation = "fall"
        self.endGamePopUp!.animateNext{
            self.endGamePopUpVC?.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.endGamePopUpVC = nil
            })
            self.restartGame()
        }
    }
    func didPressRankButton(){
        self.showLeaderboard()
    }
    func newsForPopUp()->String{
        return self.newsForPopUpView!
    }
    func currentScoreForPopUp()->String{
        return "\(self.currentScore)"
    }
    func highScoreForPopUp()->String{
        let highscore = NSUserDefaults.standardUserDefaults().valueForKey("highScore")!.unsignedIntegerValue
        return "\(highscore)"
    }
    
//    var adTimer:NSTimer?
//    var closeButton:SpringButton?
//    var closeCountDown = 5;
//    var adPending = false;
//    var pendingAd: ADInterstitialAd?;
//    var shouldShowAd = true;
//    //identifies if a loaded ad should be displayed
//    func showAdIfNeedTo(){
//        if(self.ads && (self.pendingAd != nil)){
//            self.presentAd(self.pendingAd!)
//        }
//        else if(self.ads && (--self.showAdCount) == 0){
//            self.showAdCount = 5
//            self.closeCountDown = 5;
//            self.interstitialAd = ADInterstitialAd()
//            self.interstitialAd!.delegate = self
//        }
//    }
//
//    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
//        if (self.shouldShowAd){
//            self.presentAd(interstitialAd)
//        }else{
//            self.pendingAd = interstitialAd
//        }
//    }
//    
//    func presentAd(interstitialAd:ADInterstitialAd){
//        let v = self.endGamePopUpVC!.prepareForInterstitialAd()
//        interstitialAd.presentInView(v)
//        self.showCloseButton()
//        self.pendingAd = nil
//    }
//    
//    func showCloseButton(){
//        self.closeButton = SpringButton(frame: CGRectMake(50, 50, 70, 70))
//        self.closeButton?.setTitle("5", forState: UIControlState.Normal)
//        self.closeButton?.setTitle("5", forState: UIControlState.Selected)
//        self.closeButton?.titleLabel?.font = UIFont(name: "Gill Sans", size: 36)
//        //println(self.closeButton?.titleLabel)
//        self.closeButton?.backgroundColor = UIColor.whiteColor()
//        self.closeButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//        self.closeButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
//        self.closeButton?.layer.borderWidth = 3
//        self.closeButton?.layer.cornerRadius = 36
//        self.endGamePopUp?.addSubview(self.closeButton!)
//        self.closeButton?.animation = "squeezeRight"
//        self.closeButton?.animate()
//        self.adTimer = NSTimer(timeInterval: 1, target: self, selector: "decreaseCloseCountdown", userInfo: nil, repeats: true)
//        NSRunLoop.mainRunLoop().addTimer(self.adTimer!, forMode: NSDefaultRunLoopMode)
//    }
//    
//    func decreaseCloseCountdown(){
//        if(self.closeCountDown != 0){
//            self.closeButton?.setTitle("\(self.closeCountDown)", forState: UIControlState.Normal)
//            self.closeButton?.setTitle("\(self.closeCountDown)", forState: UIControlState.Selected)
//            self.closeCountDown--
//        }else{
//            self.adTimer?.invalidate()
//            self.adTimer = nil
//            self.closeButton?.setImage(UIImage(named: "close"), forState: UIControlState.Normal)
//            self.closeButton?.addTarget(self, action: "hideInterstitial", forControlEvents: UIControlEvents.TouchUpInside)
//        }
//    }
//    
//    func hideCloseButton(){
//        self.closeButton?.removeFromSuperview()
//        self.closeButton = nil
//    }
//    
//    func hideInterstitial(){
//        self.hideCloseButton()
//        self.endGamePopUpVC?.hideInterstitialAd()
//    }
//    
//    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
//        self.interstitialAd = nil
//    }
//    
//    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
//        //println(error.localizedDescription)
//        self.interstitialAd = nil
//    }
//    
//    func bannerViewDidLoadAd(banner: ADBannerView!) {
//        if(self.adBanner.hidden){
//            self.adBanner.hidden = false
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.adBanner.alpha = 1
//                })
//        }
//    }
//    
//    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
//        //println(error.localizedDescription)
//        if(!self.adBanner.hidden){
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                self.adBanner.alpha = 0
//                }, completion: { (c:Bool) -> Void in
//                    self.adBanner.hidden = true
//            })
//        }
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


}

