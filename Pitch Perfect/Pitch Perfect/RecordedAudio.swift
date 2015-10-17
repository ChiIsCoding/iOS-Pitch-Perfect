//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Chi Zhang on 10/5/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL!, title: String!) {
        self.filePathUrl = filePathUrl
        self.title = title
    }

}
