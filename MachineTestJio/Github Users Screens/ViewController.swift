//
//  ViewController.swift
//  MachineTestJio
//
//  Created by Apurva Dongre on 17/08/20.
//  Copyright © 2020 Apurva Dongre. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController,UISearchBarDelegate{
 
    var githubuserArray : [GithubUserBean]?
    var filteredgithubuserArray: [GithubUserBean]?
    var offlineArray : [GithubUserBean]?
    var userArr : NSArray?
    var myTableView: UITableView!
    var db : OpaquePointer?
    var fileUrl : URL?
    var needInsert : String?
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        githubuserArray = [GithubUserBean]()
        filteredgithubuserArray = [GithubUserBean]()
        offlineArray = [GithubUserBean]()
        userArr = NSArray()
        setUpNavigationBar()
        setUpTable()
        setUpSearchBar()
        needInsert = "NO"
        
        fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("GithubDatabase.sqlite")

        if UIApplication.isFirstLaunch() {
            openDatabase()
            createTable()
            if(Reachability.isConnectedToNetwork()){
                needInsert = "YES"
                loadData()
            }else{
                let alert = UIAlertController.init(title: "Alert", message: "Make sure you have a worrking internet connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            if(Reachability.isConnectedToNetwork()){
                loadData()
            }else{
                print("No Internet Connection Available")
                openDatabase()
                readValues()
            }
        }
    }
    
    
  func setUpNavigationBar(){
      self.title = "Github Users"
      navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
      navigationController?.navigationBar.barTintColor = .systemPink
  }
  
  func setUpTable(){
      let displayWidth: CGFloat = self.view.frame.width
      let displayHeight: CGFloat = self.view.frame.height
      myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
      myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: 50))
      myTableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0);
      myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
      myTableView.dataSource = self
      myTableView.delegate = self
      self.view.addSubview(myTableView)
  }
  
  func setUpSearchBar(){
      searchController.searchResultsUpdater = self
      searchController.obscuresBackgroundDuringPresentation = false
      searchController.searchBar.placeholder = "Search Github User"
      definesPresentationContext = true
      myTableView.tableHeaderView = searchController.searchBar
  }

func loadData() {
    let appUrl = "https://api.github.com/search/users?q=torvalds&page=1"
    get(url: appUrl) { (success, response) in
        if success {
           weak var weakSelf = self
            if let jsonResult = response as? [String : Any] { //since there's array in API
                weakSelf?.parseJsonResponse(dict: jsonResult)
            } else {
                print("Erroer while parsing the data")
            }
        }
    }
}

func parseJsonResponse(dict:[String : Any]){
    DispatchQueue.main.async {
        self.githubuserArray!.removeAll()
        self.myTableView.reloadData()
    }
    userArr = (dict["items"] as? NSArray)!
    for arrDict in userArr! {
        let bean = GithubUserBean().initWithObject(dict: arrDict as! NSDictionary)
        githubuserArray!.append(bean as! GithubUserBean)
    }

    if needInsert == "YES"{
      self.insertIntoTable()
    }
    
    DispatchQueue.main.async {
        self.myTableView.reloadData()
    }
}
    
    
func openDatabase(){
     if sqlite3_open(fileUrl?.path, &db) != SQLITE_OK {
        print("error opening database")
    }
}

func createTable(){
    if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS GithubUsers ('login' TEXT, 'avatarUrl' TEXT, 'followersUrl' TEXT)", nil, nil, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        print("error creating table: \(errmsg)")
    }else{
       print("Table Created Successfully")
    }
}
 
func insertIntoTable(){
    for i in 0..<githubuserArray!.count{
        let login = githubuserArray![i].login
        let avatarUrl = githubuserArray![i].avatar_url
        let followersUrl = githubuserArray![i].followers_url
        
        let queryString = "INSERT INTO GithubUsers ('login','avatarUrl','followersUrl') VALUES ('\(login!)','\(avatarUrl!)','\(followersUrl!)')"
        
        if sqlite3_exec(db, queryString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("NOT OK: \(errmsg)")
        }else{
            print("OK")
        }
    }
    readValues()
}
    
func readValues(){
    self.githubuserArray!.removeAll()

   let queryString = "SELECT * FROM GithubUsers"

    var stmt:OpaquePointer?

   if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
       let errmsg = String(cString: sqlite3_errmsg(db)!)
       print("error preparing select: \(errmsg)")
       return
   }

   while(sqlite3_step(stmt) == SQLITE_ROW){
       let login = String(cString: sqlite3_column_text(stmt, 0))
       let avatarUrl = String(cString: sqlite3_column_text(stmt, 1))
       let followersUrl = String(cString: sqlite3_column_text(stmt, 2))

      let bean = GithubUserBean()
      bean.login = login
      bean.avatar_url = avatarUrl
      bean.followers_url = followersUrl

      githubuserArray?.append(bean)
   }
    print("SQLITE ARRAY COUNT \(githubuserArray!.count)")
}
}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchController.isActive){
            return filteredgithubuserArray!.count
        }else{
           return githubuserArray!.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        if(searchController.isActive){
            let login = filteredgithubuserArray![indexPath.row].login
            cell.textLabel!.text = login
            let url = URL.init(string: filteredgithubuserArray![indexPath.row].avatar_url!)
            cell.imageView?.sd_setImage(with: url, completed: nil)
        }else{
            let login = githubuserArray![indexPath.row].login
            cell.textLabel!.text = login
            let url = URL.init(string: githubuserArray![indexPath.row].avatar_url!)
            cell.imageView?.sd_setImage(with: url, completed: nil)
        }
        cell.textLabel?.textColor = .darkGray
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newViewController = UserDetailsViewController()
        if(searchController.isActive){
             newViewController.followersUrl = filteredgithubuserArray![indexPath.row].followers_url
             newViewController.name = filteredgithubuserArray![indexPath.row].login
             newViewController.imageUrl = filteredgithubuserArray![indexPath.row].avatar_url
        }else{
             newViewController.followersUrl = githubuserArray![indexPath.row].followers_url
             newViewController.name = githubuserArray![indexPath.row].login
             newViewController.imageUrl = githubuserArray![indexPath.row].avatar_url
        }
        newViewController.followersUrl = githubuserArray![indexPath.row].followers_url
        self.navigationController?.pushViewController(newViewController, animated: true)
      }
}

extension ViewController : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filteredgithubuserArray?.removeAll()
          let searchStr = searchController.searchBar.text?.lowercased()
          for Obj in githubuserArray! {
            if (Obj.login?.lowercased() .contains(searchStr!))! {
              filteredgithubuserArray?.append(Obj)
            }
          }
      myTableView.reloadData()
    }
}


