//
//  LoginViewController.swift
//  WeTalk
//
//  Created by Sam on 01/08/17.
//  Copyright © 2017 Sam. All rights reserved.
//

import UIKit
import FBSDKLoginKit

enum ViewControllers: String {
	
	case TabMenu = "TabMenuControllerID"
	
	var viewController: UIViewController {
		let storyboard = UIStoryboard(name: "Main", bundle:nil)
		return storyboard.instantiateViewController(withIdentifier: self.rawValue)
	}
}


class LoginViewController: UIViewController {
	
	override func viewDidLoad() {
//		let loginButton = LoginButton(readPermissions: [ .publicProfile ])
//		loginButton.center = view.center
//		
//		view.addSubview(loginButton)
		super.viewDidLoad()
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
