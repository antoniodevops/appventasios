//
//  TiendaBean.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 23/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class TiendaBean {
    
    //MARK: Properties
    
    var idTienda : Int
    var nombreRegion : String
    var nombreZona : String
    var nombreTienda : String
    var idPais : Int
    var idRegion : Int
    var idZona : Int
    
    init() {
        self.idTienda = 0
        self.nombreRegion = ""
        self.nombreZona = ""
        self.nombreTienda = ""
        self.idPais = 0
        self.idRegion = 0
        self.idZona = 0
    }
    
    init(idTienda: Int, nombreRegion: String, nombreZona: String, nombreTienda: String, idPais: Int, idRegion: Int, idZona: Int) {
        self.idTienda = idTienda
        self.nombreRegion = nombreRegion
        self.nombreZona = nombreZona
        self.nombreTienda = nombreTienda
        self.idPais = idPais
        self.idRegion = idRegion
        self.idZona = idZona
    }
    
}
