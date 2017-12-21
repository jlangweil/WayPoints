//
//  LoginViewController.swift
//  WayPoints
//
//  Created by apple on 12/15/17.
//  Copyright © 2017 jel enterprises. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI
import FirebaseTwitterAuthUI



class LoginViewController: UIViewController, FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if user != nil {
            print("User signed in=\(user!.displayName!)")
            self.startApp()
        }
        else {
            print("Error=\(error?.localizedDescription ?? "")")
            // TODO popup alert here
        }
    }
    
    func startApp() {
        self.performSegue(withIdentifier: "startApp", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoggedIn()

    }

    func checkLoggedIn() {
       Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
             print("User is signed in already as: \(user!.uid)")
                self.startApp()
            } else {
                // No user is signed in.
                self.login()
            }
        }
        
    }
    
    func login() {
        let authUI = FUIAuth.defaultAuthUI()
        let facebookProvider = FUIGoogleAuth()
        let googleProvider = FUIFacebookAuth()
        let twitterProvider = FUITwitterAuth()
        authUI?.delegate = self
        authUI?.providers = [googleProvider, facebookProvider, twitterProvider]
        let authViewController = authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    @IBAction func logoutUnwind(segue: UIStoryboardSegue){
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
