//
//  UserDetailsViewController.swift
//  MachineTestJio
//
//  Created by Apurva Dongre on 17/08/20.
//  Copyright © 2020 Apurva Dongre. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailsViewController: UIViewController {
    
    var followersTableView: UITableView!
    var containerView: UIView?
    var nameLabel : UILabel?
    var userImage : UIImageView?
    var followersUrl : String!
    var name : String!
    var imageUrl : String!
    var userFollowersArray : [GithubUserBean]?
    var followerArr : NSArray?

//MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .lightGray
        containerView = nil
        nameLabel = nil
        userImage = nil
        userFollowersArray = [GithubUserBean]()
        followerArr = NSArray()
        setUpNavigationBar()
        setUpViews()
        
        if(Reachability.isConnectedToNetwork()){
            loadData()
        }else{
            followersTableView.isHidden = true
            let alert = UIAlertController.init(title: "No Internet", message: "Unable to load followers list", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
//MARK: - SetUp
    func setUpNavigationBar(){
        self.title = "User Details"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0, weight: .semibold)]
        navigationController?.navigationBar.tintColor = .black
    }
    
    func setUpViews(){
        self.view.backgroundColor = .white
        let screenSize: CGRect = UIScreen.main.bounds
        if(containerView == nil) {
          containerView = UIView(frame: CGRect(x: 0, y: 80, width: screenSize.width, height: 115))
          containerView!.backgroundColor = .white
          self.view.addSubview(containerView!)
        }
        
        if(userImage == nil){
          userImage = UIImageView(frame: CGRect(x: 10, y: 20, width: 80, height: 80))
          userImage?.sd_setImage(with: URL.init(string: imageUrl), completed: nil)
          containerView?.addSubview(userImage!)
        }
        
        if(nameLabel == nil){
        nameLabel = UILabel(frame: CGRect(x: 100, y: 50, width: 200, height: 21))
        nameLabel?.textAlignment = .left
        nameLabel?.text = name
        nameLabel?.font = UIFont.systemFont(ofSize: 21)
        nameLabel?.textColor = .darkGray
        containerView?.addSubview(nameLabel!)
        }
        
        followersTableView = UITableView(frame: CGRect(x: 0, y: 195, width: screenSize.width, height: self.view.frame.height-200))
        followersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        followersTableView.dataSource = self
        followersTableView.delegate = self
        self.view.addSubview(followersTableView)
    }
    
//MARK:- Api Call
    func loadData() {
        get(url: followersUrl) { (success, response) in
            if success {
               weak var weakSelf = self
                if let jsonResult = response as? Array<Any> { //since there's array in API
                    weakSelf?.parseJsonResponse(arr: jsonResult)
                } else {
                    print("Erroer while parsing the data")
                }
            }
        }
    }
    
    func parseJsonResponse(arr : [Any]){
        for i in arr {
           let temp = i as! [String : Any]
            let tempObj = GithubUserBean().initWithObject(dict: temp as NSDictionary)
            self.userFollowersArray!.append(tempObj as! GithubUserBean)
        }
        DispatchQueue.main.async {
            self.followersTableView.reloadData()
        }
    }
}

//MARK:- TableView Methods
extension UserDetailsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFollowersArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        let login = userFollowersArray![indexPath.row].login
        cell.textLabel!.text = login
        cell.textLabel?.textColor = .darkGray
        cell.selectionStyle = .none
        let url = URL.init(string: userFollowersArray![indexPath.row].avatar_url!)
        cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "ProfilePhoto"), options: [], context: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.lightGray.withAlphaComponent(0.3)
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = .black
        header?.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let headerFrame = header?.frame
        header?.textLabel?.frame = headerFrame ?? CGRect.zero
        header?.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Followers"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
