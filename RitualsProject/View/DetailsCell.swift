//
//  DetailsCell.swift
//  RitualsTask
//
//  Created by Abhang Mane @Goldmedal on 22/01/24.
//

import UIKit

class DetailsCell: UITableViewCell {

    @IBOutlet var cellView: UIView!
    @IBOutlet weak var imageRecieved: UIImageView!
    @IBOutlet weak var pinName: UILabel!
    @IBOutlet weak var pinType: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var lastUpdated: UILabel!
    @IBOutlet var updateDetailsButton: UIButton!
    @IBOutlet var deleteDetailsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cellView.layer.cornerRadius = 10
        updateDetailsButton.layer.cornerRadius = 5
        deleteDetailsButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func updatePressed(_ sender: UIButton) {
    }
    @IBAction func deletePressed(_ sender: UIButton) {
    }
    
}
