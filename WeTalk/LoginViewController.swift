//
//  LoginViewController.swift
//  WeTalk
//
//  Created by Sam on 01/08/17.
//  Copyright © 2017 Sam. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

enum ViewControllers: String {
	
	case TabMenu = "TabMenuControllerID"
	
	var viewController: UIViewController {
		let storyboard = UIStoryboard(name: "Main", bundle:nil)
		return storyboard.instantiateViewController(withIdentifier: self.rawValue)
	}
}


class LoginViewController: UIViewController {
	
	@IBOutlet weak var name: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func anonumousLogin(_ sender: Any) {
		Auth.auth().signInAnonymously(completion: { (user, error) in // 2
			if let err = error { // 3
				print(err.localizedDescription)
				return
			}
			UserDefaults.standard.set(self.name.text!, forKey: "Name")
			UserDefaults.standard.synchronize()
			self.navigationController?.pushViewController(ViewControllers.TabMenu.viewController, animated: true)
		})
	}
	
	
	@IBAction func fbLoginClick(_ sender: Any) {
		
		facebook_getAccessToken { (_, accessToken) in
			
			guard accessToken != nil else {
				return
			}
			
			
			self.navigationController?.pushViewController(ViewControllers.TabMenu.viewController, animated: true)
		}
	}
	
	func facebook_getAccessToken(_ handler:((_ authorized: Bool, _ accessToken: String?) -> Void)?) {
		FBSDKAppEvents.activateApp()
		
		let loginManager = FBSDKLoginManager()
		
		loginManager.loginBehavior = FBSDKLoginBehavior.browser
		
		loginManager.logIn(withReadPermissions: ["email"], from: nil, handler: { (fbRequestHandler) in
			if let isCancelled = fbRequestHandler.0?.isCancelled, isCancelled == true {
				loginManager.logOut()
				handler?(false, nil)
				return
			}
			
			handler?(true, fbRequestHandler.0?.token.tokenString)
		})
	}

}
