//
//  photoTableViewCell.swift
//  Album
//
//  Created by 严思远 on 2021/12/21.
//

import UIKit

class photoTableViewCell: UITableViewCell {
    @IBOutlet weak var imageview: UIImageView!
    
    // var image = UIImage()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
