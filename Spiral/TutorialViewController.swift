//
//  TutorialViewController.swift
//  Spiral
//
//  Created by Guanqing Yan on 5/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

import UIKit
protocol TutorialViewControllerDelegate{
    func dismissButtonTapped()
}

class TutorialViewController: UIPageViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate,TutorialViewControllerDelegate {
    var images = [String]()
    
    var pageControl : UIPageControl!
    internal var dismissDelegate:TutorialViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            if (UIScreen.mainScreen().nativeBounds.height > 960) {
                images += ["content_1_169","content_2_169","content_3_169"]
            }else{
                images += ["content_1_32","content_2_32","content_3_32"]
            }
        }else if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            images += ["content_1_43","content_2_43","content_3_43"]
        }
        self.delegate = self
        self.dataSource = self
        self.setViewControllers([self.viewControllerAtIndex(0)], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        self.pageControl = UIPageControl(frame: CGRectMake(0, self.view.bounds.size.height-37, self.view.bounds.size.width, 37))
        self.view.addSubview(self.pageControl)
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let tc = viewController as! TutorialContentViewController
        let index = tc.index
        if (index == 2){
            return nil
        }else{
            return self.viewControllerAtIndex(index+1)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let tc = viewController as! TutorialContentViewController
        let index = tc.index
        if (index == 0){
            return nil
        }else{
            return self.viewControllerAtIndex(index-1)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed){
            let tc = self.viewControllers[0] as! TutorialContentViewController
            self.pageControl.currentPage = tc.index
        }
    }
    
    func viewControllerAtIndex(index:Int)->TutorialContentViewController{
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("tutorial_content") as! TutorialContentViewController
        vc.index = index
        vc.setImage(self.images[index])
        if (index == 2){
            vc.setContentLabel("Play")
        }
        vc.delegate = self
        return vc
    }
    
    func dismissButtonTapped(){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.dismissDelegate.dismissButtonTapped()
        })
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
