//
//  TiendaTableViewCell.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 13/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class TiendaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageCell : UIImageView!
    @IBOutlet weak var labelTiendaCell : UILabel!
    @IBOutlet weak var labelTotalTiendasCell : UILabel!
    @IBOutlet weak var labelTicketPromedioCell : UILabel!
    @IBOutlet weak var labelVentaPerdidaCell : UILabel!
    @IBOutlet weak var labelVentaRealCell : UILabel!
    @IBOutlet weak var labelVentaObjetivoCell : UILabel!
    @IBOutlet weak var labelTiendasText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
