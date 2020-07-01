//
//  PlaceTableViewCell.swift
//  AR TEST
//
//  Created by Book Lailert on 1/7/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet var name: UILabel!
    @IBOutlet var altitude: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
