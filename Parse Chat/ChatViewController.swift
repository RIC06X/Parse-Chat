//
//  ChatViewController.swift
//  Parse Chat
//
//  Created by Yanjie Xu on 2020/5/18.
//  Copyright © 2020 Yanjie Xu. All rights reserved.
//

import UIKit
import Parse
class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chatMessageField: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 50
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadMessage()
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadMessage), userInfo: nil, repeats: true)
    }
    
    @objc func reloadMessage(){
        print("reloading Message...")
        let query = PFQuery(className: "Message")
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.chatTableView.reloadData()
            }
            else{
                print("Error in Refresh new posts: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        let post = posts[indexPath.row]
        
        //let user = post["user"] as! PFUser
        let message = post["text"] as! String
        
        cell.cellMessageLabel.text = message
        if let user = post["user"] as? PFUser {
           // User found! update username label with username
           cell.userNameLabel.text = user.username
        } else {
           // No user found, set default username
           cell.userNameLabel.text = "🤖"
        }
        
        return cell
    }
    
    @IBAction func onSend(_ sender: Any) {
        let chatMessage = PFObject(className: "Message")
        chatMessage["text"] = chatMessageField.text ?? ""
        chatMessage["user"] = PFUser.current()
        chatMessage.saveInBackground { (success, error) in
            if success {
               print("The message was saved!")
            } else if let error = error {
               print("Problem saving message: \(error.localizedDescription)")
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
