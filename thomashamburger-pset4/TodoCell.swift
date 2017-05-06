//
//  TodoCell.swift
//  thomashamburger-pset4
//
//  Created by Thomas Hamburger on 06-05-17.
//  Copyright © 2017 Thomas Hamburger. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var todoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
