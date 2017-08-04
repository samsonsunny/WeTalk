//
//  ChatViewController.swift
//  WeTalk
//
//  Created by Sam on 04/08/17.
//  Copyright © 2017 Sam. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

final class ChatViewController: JSQMessagesViewController {
	
	// MARK: Properties
	var channelRef: DatabaseReference?
	var channel: Channel? {
		didSet {
			title = channel?.name
		}
	}
	var messages = [JSQMessage]()
	lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
	lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
	
	private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
	private var newMessageRefHandle: DatabaseHandle?
	
	// MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.senderId = Auth.auth().currentUser?.uid
		collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
		collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
		observeMessages()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// animates the receiving of a new message on the view
		finishReceivingMessage()
	}
	
	// MARK: Collection view data source (and related) methods
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
		return messages[indexPath.item]
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return messages.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
		let message = messages[indexPath.item]
  
		if message.senderId == senderId {
			cell.textView?.textColor = UIColor.white
		} else {
			cell.textView?.textColor = UIColor.black
		}
		return cell
	}
	
	
	override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
		let itemRef = messageRef.childByAutoId() // 1
		let messageItem = [ // 2
			"senderId": senderId!,
			"senderName": senderDisplayName!,
			"text": text!,
			]
  
		itemRef.setValue(messageItem) // 3
  
		JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
  
		finishSendingMessage() // 5
	}
	
	private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
		let bubbleImageFactory = JSQMessagesBubbleImageFactory()
		return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
	}
	
	private func setupIncomingBubble() -> JSQMessagesBubbleImage {
		let bubbleImageFactory = JSQMessagesBubbleImageFactory()
		return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
		let message = messages[indexPath.item] // 1
		if message.senderId == senderId { // 2
			return outgoingBubbleImageView
		} else { // 3
			return incomingBubbleImageView
		}
	}
	
	override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
		return nil
	}
	
	// MARK: Firebase related methods
	private func addMessage(withId id: String, name: String, text: String) {
		if let message = JSQMessage(senderId: id, displayName: name, text: text) {
			messages.append(message)
		}
	}
	
	private func observeMessages() {
		messageRef = channelRef!.child("messages")
		// 1.
		let messageQuery = messageRef.queryLimited(toLast:25)
		
		// 2. We can use the observe method to listen for new
		// messages being written to the Firebase DB
		newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
   // 3
			let messageData = snapshot.value as! Dictionary<String, String>
			
			if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
	// 4
				self.addMessage(withId: id, name: name, text: text)
	
	// 5
				self.finishReceivingMessage()
			} else {
				print("Error! Could not decode message data")
			}
		})
	}
	// MARK: UI and User Interaction
	
	
	// MARK: UITextViewDelegate methods
	
}

