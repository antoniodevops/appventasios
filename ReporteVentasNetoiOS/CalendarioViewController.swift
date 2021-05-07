//
//  CalendarioViewController.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 22/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class CalendarioViewController: UIViewController {
    
    var usuarioIdSegue = Int()
    var tipoBusquedaSegue = Int()
    var tipoTiendaSegmentedSegue = Int();
    
    var regionSegue = Int();
    var zonaSegue = Int();
    var tiendaSegue = Int();
    var ubicacion = String();
    
    let TIPO_TIENDA_ACTIVA = Int(1);
    let TIPO_TIENDA_NUEVA = Int(2);

    @IBOutlet weak var calendario: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var components = DateComponents()
        let maxDate = Calendar.current.date(byAdding: components, to: Date())
        
        if(tipoTiendaSegmentedSegue == TIPO_TIENDA_ACTIVA) {
            components.year = -2
        } else if(tipoTiendaSegmentedSegue == TIPO_TIENDA_NUEVA) {
            components.month = -4
        }
        
        let minDate = Calendar.current.date(byAdding: components, to: Date())
        
        calendario.minimumDate = minDate
        calendario.maximumDate = maxDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func back(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        NSLog(formatter.string(from: calendario.date))
        
        let principalView = self.storyboard?.instantiateViewController(withIdentifier: "VistaRegionesView") as! ViewController
        principalView.fechaSegue = formatter.string(from: calendario.date)
        principalView.esPopVistaSegue = false
        principalView.usuarioIdSegue = usuarioIdSegue
        principalView.tipoBusquedaSegue = tipoBusquedaSegue
        principalView.tipoTiendaSegmentedSegue = tipoTiendaSegmentedSegue
        principalView.tipoTienda = tipoTiendaSegmentedSegue
        principalView.tipoTiendaSegue = tipoTiendaSegmentedSegue
        principalView.tipoBusquedaSegue = tipoBusquedaSegue
        principalView.region = regionSegue
        principalView.zona = zonaSegue
        principalView.tienda = tiendaSegue
        principalView.ubicacion = ubicacion;
        principalView.infoBotonBandera = false;
        //self.dismiss(animated: true, completion: nil)
        principalView.actualizaConsultaPorFecha()
        self.present(principalView, animated: true, completion: nil)
    }
}



