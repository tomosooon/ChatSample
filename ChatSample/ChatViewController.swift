//
//  ViewController.swift
//  ChatSample
//
//  Created by tomoaki saito on 2015/06/20.
//  Copyright (c) 2015年 mikan. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextViewDelegate {
    var myRootRef: Firebase!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Nameにラベルを設定。"Guest"に0〜9をランダムで付与。
        self.nameLabel.text = "Guest\(arc4random() % 10)"
        // Return時のイベントをハンドルするために登録
        self.inputField.delegate = self
        
        // Firebaseへ接続
        self.myRootRef = Firebase(url: "https://radiant-heat-3445.firebaseio.com/chat1/posts")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.myRootRef.childByAutoId().setValue([
            "name": self.nameLabel.text,
            "data": textField.text
            ])
        textField.text = ""
        
        return true
    }
}

