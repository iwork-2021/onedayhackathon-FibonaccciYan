//
//  imageItem.swift
//  Album
//
//  Created by 严思远 on 2021/12/21.
//

import UIKit

class imageItem: NSObject {
    var image: UIImage
    var tag: String
    
    init(_image: UIImage, _tag: String) {
        self.image = _image
        self.tag = _tag
    }
}
