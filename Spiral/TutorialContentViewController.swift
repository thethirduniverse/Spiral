//
//  TutorialContentViewController.swift
//  Spiral
//
//  Created by Guanqing Yan on 5/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    internal var index:Int!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: SpringButton!

    internal var delegate:TutorialViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setImage(name:String){
        let v = self.view
        self.imageView.image = UIImage(named: name)
    }
    
    func setContentLabel(label:String){
        self.playButton.titleLabel?.text = label
        self.playButton.hidden = false;
    }
    @IBAction func playButtonTapped(sender: AnyObject) {
        self.delegate.dismissButtonTapped()
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
