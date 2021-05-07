//
//  UsuarioBean.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 23/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class UsuarioBean {
    
    //MARK: Properties
    
    var esUsuarioValido : Bool
    var usuarioId: Int
    var nombreUsuario : String
    
    init() {
        self.esUsuarioValido = false
        self.usuarioId = 0
        self.nombreUsuario = ""
    }
    
    init(esUsuarioValido: Bool, usuarioId: Int, nombreUsuario: String) {
        self.esUsuarioValido = esUsuarioValido
        self.usuarioId = usuarioId
        self.nombreUsuario = nombreUsuario
    }
    
}
