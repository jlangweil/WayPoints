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
    
    var firstTimeUser : Bool = false
    
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
    
    private func startApp() {
        if firstTimeUser {
            self.performSegue(withIdentifier: "showTutorialForFirstTime", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "startApp", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.contains(key: "firstTimeUser") {
            firstTimeUser = defaults.bool(forKey: "firstTimeUser")
        }
        else {
            firstTimeUser = true // we are using for the first time, or first time with this value, show the tutorial
            defaults.set(false, forKey: "firstTimeUser") // set the value so next time we don't show the tutoral
        }
        checkLoggedIn()

    }

    private func checkLoggedIn() {
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
    
     private func login() {
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
    

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTutorialForFirstTime" {
             if let navigationVC = segue.destination as? UINavigationController, let tutorialVC = navigationVC.topViewController as? TutorialPageViewController {
                //tutorialVC.comingFromHelpScreen = false
            }
        }
    }*/

}
