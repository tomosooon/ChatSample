//
//  ViewController.swift
//  ChatSample
//
//  Created by tomoaki saito on 2015/06/20.
//  Copyright (c) 2015年 mikan. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController, UITextFieldDelegate {
    var myRootRef: Firebase!
    
    var messages: Array<JSQMessage> = []
    var incomingBubble: JSQMessagesBubbleImage? = nil
    var outgoingBubble: JSQMessagesBubbleImage? = nil
    var incomingAvatar: JSQMessagesAvatarImage? = nil
    var outgoingAvatar: JSQMessagesAvatarImage? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = UIDevice.currentDevice().identifierForVendor.UUIDString
        self.senderDisplayName = "First Chat"
        
        let bubbleFactory: JSQMessagesBubbleImageFactory = JSQMessagesBubbleImageFactory.new()
        self.incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "user2.jpeg"), diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "user1.jpg"), diameter: 64)
        
        // Firebaseへ接続
        self.myRootRef = Firebase(url: "https://radiant-heat-3445.firebaseio.com/chat1/posts")

        // Child追加時のイベントハンドラ
        self.myRootRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if let name = snapshot.value.objectForKey("name") as? String {
                if let data = snapshot.value.objectForKey("data") as? String {
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    // 新しいメッセージデータを追加する
                    let message: JSQMessage = JSQMessage(senderId: name, displayName: self.senderDisplayName, text: data)
                    self.messages.append(message)
                    self.finishReceivingMessageAnimated(true)
                    if name != self.senderId {
                    }
                }
            }
        })
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.myRootRef.childByAutoId().setValue([
            "name": self.senderId,
            "data": textField.text
            ])
        textField.text = ""
        
        return true
    }
    
    //MARK: jsq message delegate
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        let message: JSQMessage = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.myRootRef.childByAutoId().setValue([
            "name": senderId,
            "data": text
            ])
        self.finishSendingMessageAnimated(true)
    }
    
    //MARK: jsq message datasource
    // background image for each message
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubble
        } else {
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item]
        println("collection")
        println(message.senderId)
        println(self.senderId)
        if message.senderId == self.senderId {
            return self.outgoingAvatar
        } else {
            return self.incomingAvatar
        }
    }
    
    //MARK: collection view datasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
}

