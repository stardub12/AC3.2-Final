//
//  Post.swift
//  AC3.2-Final
//
//  Created by Simone on 2/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import Foundation

class Post {
    var feedImage: String?
    var comment: String?
    
    init(feedImage: String, comment: String) {
        self.feedImage = feedImage
        self.comment = comment
    }
    
    var asDictionary: [String:String] {
        return ["image": feedImage!, "comment": comment!]
    }
}
