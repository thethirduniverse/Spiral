//
//  endGamePopUpViewController.swift
//  Spiral
//
//  Created by Guanqing Yan on 5/16/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

import UIKit
protocol endGamePopUpProtocol{
    func didPressShareButton()
    func didPressReplayButton()
    func didPressRankButton()
//    func didPressNoAd()
//    func didPressRestoreButton()
    func newsForPopUp()->String
    func currentScoreForPopUp()->String
    func highScoreForPopUp()->String
}

class endGamePopUpViewController: UIViewController {
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var rankButton: UIButton!
    @IBOutlet weak var noadButton: UIButton!
    @IBOutlet weak var contentView: UIVisualEffectView!
    
    @IBOutlet weak var restoreButton: UIButton!
    
    
    internal var interstitialAdView: UIView!
    var delegate:endGamePopUpProtocol?{
        didSet{
            loadData()
        }
    }
    override func viewDidLoad(){
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.shadowRadius = 5
        self.contentView.layer.shadowOffset = CGSizeMake(1, 1)
        self.shareButton.layer.cornerRadius = self.shareButton.bounds.width/2
        self.replayButton.layer.cornerRadius = self.replayButton.bounds.width/2
        self.rankButton.layer.cornerRadius = self.rankButton.bounds.width/2
        self.noadButton.layer.cornerRadius = self.noadButton.bounds.width/2
        self.shareButton.layer.borderWidth = 5
        self.rankButton.layer.borderWidth = 5
        self.replayButton.layer.borderWidth = 5
        self.noadButton.layer.borderWidth = 5
        self.restoreButton.layer.cornerRadius = self.noadButton.bounds.width/2
        self.restoreButton.layer.borderWidth = 5

    }
    @IBAction func didPressRestore(sender: AnyObject) {
        self.delegate?.didPressRestoreButton();
    }
    @IBAction func didPressReplay(sender: AnyObject) {
        self.delegate?.didPressReplayButton()
    }
    @IBAction func didPressShare(sender: AnyObject) {
        self.delegate?.didPressShareButton()
    }
    @IBAction func didPressRank(sender: AnyObject) {
        self.delegate?.didPressRankButton()
    }
    @IBAction func didPressNoAd(sender: AnyObject) {
        self.delegate?.didPressNoAd()
    }
    
    func loadData(){
        self.currentScoreLabel.text = self.delegate?.currentScoreForPopUp()
        self.highScoreLabel.text = self.delegate?.highScoreForPopUp()
        self.newsLabel.text = self.delegate?.newsForPopUp()
    }
    internal func prepareForInterstitialAd()->UIView{
        self.interstitialAdView = UIView(frame: self.view.bounds)
        //println(self.interstitialAdView)
        //println(self.view)
        self.view.addSubview(self.interstitialAdView)
        self.interstitialAdView.backgroundColor = UIColor.clearColor()
        return self.interstitialAdView
    }
    
    internal func hideInterstitialAd(){
        self.interstitialAdView.removeFromSuperview()
        self.interstitialAdView = nil
    }
    
    internal func showAlert(alert:UIAlertView){
        alert.show()
    }
}
