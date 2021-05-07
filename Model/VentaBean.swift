//
//  VentaBean.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 22/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class VentaBean {
    
    //MARK: Properties
    
    var idElemento : Int 
    var nombreElemento : String
    var numeroTiendas : Int
    var ticketPromedio : Double
    var ventaPerdida : Double
    var ventaReal : Double
    var ventaObjetivo : Double
    
    init() {
        self.idElemento = 0
        self.nombreElemento = ""
        self.numeroTiendas = 0
        self.ticketPromedio = 0
        self.ventaPerdida = 0.0
        self.ventaReal = 0.0
        self.ventaObjetivo = 0.0
    }
    
    init(idElemento: Int, nombreElemento: String, numeroTiendas: Int, ticketPromedio: Double, ventaPerdida: Double, ventaReal: Double, ventaObjetivo: Double) {
        self.idElemento = idElemento
        self.nombreElemento = nombreElemento
        self.numeroTiendas = numeroTiendas
        self.ticketPromedio = ticketPromedio
        self.ventaPerdida = ventaPerdida
        self.ventaReal = ventaReal
        self.ventaObjetivo = ventaObjetivo
    }
    
    
}
