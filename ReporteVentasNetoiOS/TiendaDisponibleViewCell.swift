//
//  TiendaDisponibleViewCell.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 23/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class TiendaDisponibleViewCell: UITableViewCell {

    @IBOutlet weak var numeroTienda: UILabel!
    @IBOutlet weak var nombreTienda: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
