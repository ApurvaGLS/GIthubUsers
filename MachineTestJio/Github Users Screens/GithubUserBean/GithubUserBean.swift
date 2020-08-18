//
//  GithubUserBean.swift
//  MachineTestJio
//
//  Created by Apurva Dongre on 17/08/20.
//  Copyright © 2020 Apurva Dongre. All rights reserved.
//

import UIKit

class GithubUserBean: NSObject {
    var login: String?
    var url : String?
    var followers_url : String?
    var avatar_url : String?
    
    func initWithObject(dict: NSDictionary) -> AnyObject {
      if let login = dict["login"] as? String {
        self.login = login
      }
      if let url = dict["url"] as? String {
        self.url = url
      }
      if let followers_url = dict["followers_url"] as? String {
        self.followers_url = followers_url
      }
      if let avatar_url = dict["avatar_url"] as? String {
        self.avatar_url = avatar_url
      }
      return self
    }
}
