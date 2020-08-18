//
//  ApiHandlerClass.swift
//  MachineTestJio
//
//  Created by Apurva Dongre on 17/08/20.
//  Copyright © 2020 Apurva Dongre. All rights reserved.
//

import Foundation
func get(url: String, completion:@escaping (_ success: Bool, _ response: Any) ->()) {
    let url = URL(string: url)
    var request = URLRequest(url: url!)
    request.httpMethod = "GET"
    let session = URLSession.shared
    let dataTask = session.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
        if error != nil {
            print("Error in GET method")
            let dict:[String : Any] = ["code" : "Error"]
            completion(false,dict)
        }
        do {
            let rootDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
            completion(true,rootDictionary)
        } catch {
            print("Error while JSON Parsing")
            let dict:[String : Any] = ["code" : "Error"]
            completion(false,dict)
        }
    }
    dataTask.resume()
}


