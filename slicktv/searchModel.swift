//
//  searchModel.swift
//  slicktv
//
//  Created by Stanley Chiang on 5/4/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import SwiftyJSON

protocol queryDelegate {
    func searchCompleted(result:Array<String>)
}

class searchModel:NSObject {
    
    static let sharedInstance = searchModel()
    private override init() {}
    
    var delegate:queryDelegate?
    
    func makePromiseQueryTVShow(queryText:String) -> Promise<AnyObject> {
        return Promise { fulfill, reject in
            let encodedTVShow:String = "http://api.tvmaze.com/search/shows?q=\((queryText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet()))!)"
            
            Alamofire.request(.GET, encodedTVShow).responseJSON { response in
                if response.result.isSuccess {
                    fulfill(response.result.value!)
                }else{
                    reject(response.result.error!)
                }
            }
        }
    }
    
    func searchForTVShow(queryText:String){
        var parsedArray: Array = [String]()
        
        makePromiseQueryTVShow(queryText).then { (tvMazeSearchResults) -> Void in
            for (_,subJson):(String, JSON) in JSON(tvMazeSearchResults) {
                if let showName = subJson["show"]["name"].string {
                    parsedArray.append(showName)
                }
            }
            
            self.delegate?.searchCompleted(parsedArray)
        }
    }
    
}