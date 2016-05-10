//
//  GoogleSigninViewController.swift
//  EasyMusic
//
//  Created by Selvaraju Vignesh on 8/5/16.
//  Copyright © 2016 madlife. All rights reserved.
//

import UIKit

class GoogleSigninViewController: UIViewController , GIDSignInUIDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().signIn()
        //[[GIDSignIn sharedInstance] signIn];
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    


    @IBAction func LogoutTapped(sender: AnyObject) {
            GIDSignIn.sharedInstance().signOut()
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