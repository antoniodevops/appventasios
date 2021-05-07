//
//  ViewController.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 13/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit
import Alamofire
import UICircularProgressRing

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, NSURLConnectionDelegate,NSURLConnectionDataDelegate,  XMLParserDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var ventaRealLabel: UILabel!
    @IBOutlet weak var ventaObjetivoLabel: UILabel!
    @IBOutlet weak var vtaObjetivoTotalLabel: UILabel!
    @IBOutlet weak var vtaObjetivoTotalDescLabel: UILabel!
    @IBOutlet weak var tiendasVentaLabel: UILabel!
    @IBOutlet weak var ticketPromedioLabel: UILabel!
    @IBOutlet weak var ventaPerdidaLabel: UILabel!
    @IBOutlet weak var rangoFechasLabel: UILabel!
    @IBOutlet weak var porcentajeVenta: UIProgressView!
    @IBOutlet weak var ventaObjetivoDescLabel: UILabel!
    @IBOutlet weak var ventasHoyBoton: UIButton!
    @IBOutlet weak var ventasSemanaBoton: UIButton!
    @IBOutlet weak var ventasMesBoton: UIButton!
    @IBOutlet weak var regionHeaderLabel: UILabel!
    @IBOutlet weak var navBackBoton: UIButton!
    @IBOutlet weak var nombreUbicacion: UILabel!
    @IBOutlet weak var porcentajeVentaCircular: UICircularProgressRingView!
    @IBOutlet weak var filtroSinVentasBoton: UIButton!
    @IBOutlet weak var filtroTipoPptoBoton: UIButton!
    @IBOutlet weak var tipoTiendaSegmented: UISegmentedControl!
    @IBOutlet weak var tipoTiendaBoton: UIButton!
    @IBOutlet weak var infoBoton: UIButton!
    
    var eName: String = String()
    var codigo = Int();
    var mensaje = String();
    var ubicacion = String();
    var ubicacionRegion = String();
    var ubicacionZona = String();
    var ubicacionTienda = String();
    var ventaBean = VentaBean();
    var porcentaje = Double();
    var ventaReal = Int64();
    var ventaObjetivo = Int64();
    var ventaObjetivoTotal = Int64();
    var listaRegionesFiltradas: Array<VentaBean> = Array()
    var listaRegiones: Array<VentaBean> = Array()
    var fechaInicial = String();
    var fechaFinal = String();
    var infoBotonBandera = true;
    
    var usuarioIdSegue = Int();
    var tipoTiendaSegue = Int();
    var tipoTiendaSegmentedSegue = Int(1);
    var fechaSegue = String();
    var esPopVistaSegue = true;
    var tipoBusquedaSegue = Int(1);
    var banderaFiltro = false;
    var banderaFiltroPpto = true;
    var banderaPorTienda = false;
    var banderaUltimoNivel = false;
    
    var region = Int(0);
    var zona = Int(0);
    var tienda = Int(0);
    
    let alertVentas = UIAlertController(title: nil, message: "Buscando ventas", preferredStyle: .alert)
    let tipoBusquedaDia = Int(1);
    let tipoBusquedaSemana = Int(2);
    let tipoBusquedaMes = Int(3);
    
    let TIPO_TIENDA_ACTIVA = Int(1);
    let TIPO_TIENDA_NUEVA = Int(2);
    let TIPO_TIENDA_CON_VENTA = Int(1);
    let TIPO_TIENDA_SIN_VENTA = Int(0);
    let TIPO_PPTO_OPERATIVO = Int(1);
    let TIPO_PPTO_FINANZAS = Int(2);
    
    var tipoTienda = Int(1);
    var tipoVenta = Int(1);
    var tipoPpto = Int(2);
    
    
    var mutableData:NSMutableData  = NSMutableData()
    var currentElementName:String = ""
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //tiendasFiltradas = tiendasList;
        //listaRegionesFiltradas = listaRegiones;
        
        /*searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar*/
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if esPopVistaSegue {
            ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA ON"), for: UIControlState.normal)
            ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA OFF"), for: UIControlState.normal)
            ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES OFF"), for: UIControlState.normal)
            fechaInicial = obtieneFechaHoy();
            fechaFinal = obtieneFechaHoy();
            
            limpiaVista()
            ejecutaWS()
        }
        
        vtaObjetivoTotalLabel.isHidden = true
        vtaObjetivoTotalDescLabel.isHidden = true
        ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 355)
        ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 355)
        
        if(tipoTiendaSegmentedSegue == TIPO_TIENDA_ACTIVA) {
            tipoTiendaSegmented.selectedSegmentIndex = 0
        } else {
            tipoTiendaSegmented.selectedSegmentIndex = 1
        }
        
        
        if(tipoTienda == TIPO_TIENDA_ACTIVA) {
            tipoTiendaBoton.setBackgroundImage(UIImage(named: "carritopuerta_azul"), for: UIControlState.normal)
        } else if(tipoTienda == TIPO_TIENDA_NUEVA) {
            tipoTiendaBoton.setBackgroundImage(UIImage(named: "carritopuerta_naranja"), for: UIControlState.normal)
        }
        if(tipoVenta == TIPO_TIENDA_CON_VENTA) {
            filtroSinVentasBoton.setBackgroundImage(UIImage(named: "carritoturquesa"), for: UIControlState.normal)
        } else if(tipoVenta == TIPO_TIENDA_SIN_VENTA) {
            filtroSinVentasBoton.setBackgroundImage(UIImage(named: "carritopuerta_naranja"), for: UIControlState.normal)
        }
        if(tipoPpto == TIPO_PPTO_OPERATIVO) {
            filtroTipoPptoBoton.setBackgroundImage(UIImage(named: "pptoturquesa"), for: UIControlState.normal)
        } else if(tipoPpto == TIPO_PPTO_FINANZAS) {
            filtroTipoPptoBoton.setBackgroundImage(UIImage(named: "pptonaranja"), for: UIControlState.normal)
        }
        
        if(!infoBotonBandera) {
            alertVentas.view.tintColor = UIColor.black
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alertVentas.view.addSubview(loadingIndicator)
            infoBotonBandera = false;
            present(alertVentas, animated: true, completion: nil)
        }
        
        if(tipoBusquedaSegue == tipoBusquedaDia) {
            vtaObjetivoTotalLabel.isHidden = true
            vtaObjetivoTotalDescLabel.isHidden = true
            
            ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 355)
            ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 355)
        } else if(tipoBusquedaSegue == tipoBusquedaSemana) {
            vtaObjetivoTotalLabel.isHidden = false
            vtaObjetivoTotalDescLabel.isHidden = false
            
            ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
            ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
        } else if(tipoBusquedaSegue == tipoBusquedaMes) {
            vtaObjetivoTotalLabel.isHidden = false
            vtaObjetivoTotalDescLabel.isHidden = false
            
            ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
            ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaRegiones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TiendasCell", for: indexPath) as! TiendaTableViewCell
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        if(tipoTienda == TIPO_TIENDA_ACTIVA && tipoVenta == TIPO_TIENDA_CON_VENTA) {
            cell.labelTiendaCell.text = listaRegiones[indexPath.row].nombreElemento
        } else if((tipoTienda == TIPO_TIENDA_ACTIVA && tipoVenta == TIPO_TIENDA_SIN_VENTA) || tipoTienda == TIPO_TIENDA_NUEVA) {
            var arreglo = listaRegiones[indexPath.row].nombreElemento.components(separatedBy: "/")
            
            if(arreglo != nil && !arreglo.isEmpty && arreglo.count >= 3) {
                cell.labelTiendaCell.text = arreglo[2];
            } else {
                cell.labelTiendaCell.text = "Tienda"
            }
        } else if(tipoTienda == TIPO_TIENDA_NUEVA) {
            
        }
        cell.labelTotalTiendasCell.text = "\(listaRegiones[indexPath.row].numeroTiendas)"
        cell.labelTicketPromedioCell.text = "$ " + numberFormatter.string(from: NSNumber(value:listaRegiones[indexPath.row].ticketPromedio))! + ""
        cell.labelVentaPerdidaCell.text = "$ " + numberFormatter.string(from: NSNumber(value:listaRegiones[indexPath.row].ventaPerdida))! + ""
        cell.labelVentaRealCell.text = "$ " + numberFormatter.string(from: NSNumber(value:listaRegiones[indexPath.row].ventaReal))!
        cell.labelVentaObjetivoCell.text = "$ " + numberFormatter.string(from: NSNumber(value:listaRegiones[indexPath.row].ventaObjetivo))!
        
        if(region > 0 && zona > 0) {
            cell.labelTiendasText.text = "Transacciones"
        } else {
            cell.labelTiendasText.text = "Tiendas"
        }
        
        let porcentaje = (listaRegiones[indexPath.row].ventaReal / listaRegiones[indexPath.row].ventaObjetivo) * 100
        if  porcentaje > 80 {
            cell.imageCell.image = UIImage(named: "verde")
        } else if porcentaje > 60 {
            cell.imageCell.image = UIImage(named: "amarillo")
        } else {
            cell.imageCell.image = UIImage(named: "rojo")
        }
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        if(banderaUltimoNivel) {
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.isUserInteractionEnabled = false
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.gray;
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*let alertController = UIAlertController(title: "Hint", message: "You have selected row \(indexPath.row).", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)*/
        //let zonasView =  self.storyboard?.instantiateViewController(withIdentifier: "VistaZonasView") as! UIViewController
        //self.present(zonasView, animated: true, completion: nil)
        
        //ubicacion = listaRegiones[indexPath.row].nombreElemento
        
        if(tipoTienda == TIPO_TIENDA_NUEVA || tipoVenta == TIPO_TIENDA_SIN_VENTA) {
            tienda = listaRegiones[indexPath.row].idElemento
            ubicacion = listaRegiones[indexPath.row].nombreElemento
            filtroSinVentasBoton.isEnabled = false
            tipoTiendaBoton.isEnabled = false
            banderaUltimoNivel = true
        } else {
            if region == 0 && zona == 0 && tienda == 0 {
                region = listaRegiones[indexPath.row].idElemento
                ubicacionRegion = listaRegiones[indexPath.row].nombreElemento;
                ubicacion = ubicacionRegion
                filtroSinVentasBoton.isEnabled = true
                tipoTiendaBoton.isEnabled = true
            } else if region > 0 && zona == 0 && tienda == 0 {
                zona = listaRegiones[indexPath.row].idElemento
                ubicacionZona = listaRegiones[indexPath.row].nombreElemento;
                //ubicacion = ubicacionRegion + " / " + ubicacionZona;
                ubicacion += " / " + ubicacionZona
                filtroSinVentasBoton.isEnabled = true
                tipoTiendaBoton.isEnabled = true
            } else {
                tienda = listaRegiones[indexPath.row].idElemento
                ubicacionTienda = listaRegiones[indexPath.row].nombreElemento;
                //ubicacion = ubicacionRegion + " / " + ubicacionZona + " / " + ubicacionTienda;
                ubicacion += " / " + ubicacionTienda
                filtroSinVentasBoton.isEnabled = false
                tipoTiendaBoton.isEnabled = false
                banderaUltimoNivel = true
            }
        }
        limpiaVista()
        ejecutaWS()
    }
    
    /*
    func filterContentForSearchText(searchText: String) {
        
        self.speciesSearchResults = self.species!.filter({( tiendasList: StarWarsSpecies) -> Bool in
            // to start, let's just search by name
            return aSpecies.name!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }*/
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            //tiendasFiltradas = tiendasList
        } else {
            // Filter the results
            //tiendasFiltradas = tiendasList.filter { $0.nombre.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        self.tableView.reloadData()
    }
    
    func actualizaConsultaPorFecha() {
        if tipoBusquedaSegue == tipoBusquedaDia {
            self.fechaInicial = fechaSegue
            self.fechaFinal = fechaSegue
            if(vtaObjetivoTotalLabel != nil) {
                vtaObjetivoTotalLabel.isHidden = true
                ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 355)
            }
            if(vtaObjetivoTotalDescLabel != nil) {
                vtaObjetivoTotalDescLabel.isHidden = true
                ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 355)
            }
        } else if tipoBusquedaSegue == tipoBusquedaSemana {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = dateFormatter.date(from: fechaSegue)!
            
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "en_US_POSIX")
            let weekDay = calendar.component(.weekday, from: date)
            var dateComponents = DateComponents()
            dateComponents.day = (weekDay - 2) * (-1)
            let fechaInicial2 = Calendar.current.date(byAdding: dateComponents, to: date);
            
            //self.fechaInicial = dateFormatter.string(from: fechaInicial2!)
            self.fechaFinal = dateFormatter.string(from: date)
            self.fechaInicial = obtieneFechaPrimerDiaSemanaPorString();
            
            if(vtaObjetivoTotalLabel != nil) {
                vtaObjetivoTotalLabel.isHidden = false
                ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
            }
            if(vtaObjetivoTotalDescLabel != nil) {
                vtaObjetivoTotalDescLabel.isHidden = false
                ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = dateFormatter.date(from: fechaSegue)!
            
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "en_US_POSIX")
            let dia = calendar.component(.day, from: date)
            var dateComponents = DateComponents()
            dateComponents.day = (dia - 1) * (-1)
            let fechaInicial2 = Calendar.current.date(byAdding: dateComponents, to: date);
            
            self.fechaInicial = dateFormatter.string(from: fechaInicial2!)
            self.fechaFinal = dateFormatter.string(from: date)
            if(vtaObjetivoTotalLabel != nil) {
                vtaObjetivoTotalLabel.isHidden = false
                ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
            }
            if(vtaObjetivoTotalDescLabel != nil) {
                vtaObjetivoTotalDescLabel.isHidden = false
                ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
            }
        }
        //limpiaVista()
        infoBotonBandera = true;
        ejecutaWS()
    }
    
    func actualizaConsultaPorTienda() {
        //limpiaVista()
        banderaPorTienda = true;
        banderaUltimoNivel = true;
        ejecutaWS()
        if tipoBusquedaSegue == tipoBusquedaDia {
            vtaObjetivoTotalLabel.isHidden = true
            vtaObjetivoTotalDescLabel.isHidden = true
            ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 355)
            ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 355)
        } else if tipoBusquedaSegue == tipoBusquedaSemana {
            vtaObjetivoTotalLabel.isHidden = false
            vtaObjetivoTotalDescLabel.isHidden = false
            ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
            ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
        } else {
            vtaObjetivoTotalLabel.isHidden = false
            vtaObjetivoTotalDescLabel.isHidden = false
            ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
            ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
        }
        filtroSinVentasBoton.isEnabled = false
        tipoTiendaBoton.isEnabled = false
    }
    
    func ejecutaWS() {
        
        alertVentas.view.tintColor = UIColor.black
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alertVentas.view.addSubview(loadingIndicator)
        present(alertVentas, animated: true, completion: nil)
        
        //NSLog("*** Usuario: \(usuarioIdSegue)")
        NSLog("*** fechaInicial: " + fechaInicial)
        NSLog("*** fechaFinal: " + fechaFinal)
        
        NSLog("*** Region: \(region)" )
        NSLog("*** Zona: \(zona)" )
        NSLog("*** Tienda: \(tienda)" )
        NSLog("*** tipoTienda: \(tipoTienda)" )
        NSLog("*** tipoVenta: \(tipoVenta)" )
        NSLog("*** tipoPresupuesto: \(tipoPpto)" )
        
        //Make the request
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = TimeInterval(30)
        configuration.timeoutIntervalForRequest = TimeInterval(30)
        _ = Alamofire.SessionManager(configuration: configuration)
        
        let parameters: Parameters = [
            "numeroEmpleado": usuarioIdSegue,
            "region": region,
            "zona": zona,
            "tienda": tienda,
            "fechaInicial":fechaInicial,
            "fechaFinal":fechaFinal,
            "tipoConsulta":tipoBusquedaSegue,
            "tipoTienda":tipoTienda,
            "tipoVenta":tipoVenta,
            "tipoPresupuesto":tipoPpto
        ]
        
        Alamofire.request(obtieneUrlPropiedades() + "obtieneVentasPorEmpleado2",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding(destination: .queryString)).validate(statusCode: 200..<300).responseString {
                            
                response in //debugPrint(response.result.value!)
                    
                    NSLog(response.description)
                            
                switch (response.result) {
                    case .success:
                        //Success....
                        let cadenaSoap = response.result.value!
                                
                        let xmlData = cadenaSoap.data(using: String.Encoding.utf8)!
                        let xmlParser = XMLParser(data: xmlData)
                        xmlParser.delegate = self as XMLParserDelegate
                        xmlParser.parse()
                        break
                    case .failure(let error):
                        // failure...
                        self.alertVentas.dismiss(animated: false, completion: nil)
                                
                        let alert = UIAlertController(title: "Error", message: "Error en la comunicación con el servicio: " + error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
    
   
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        
        if (elementName.range(of: "codigo") != nil) {
            codigo = 0
        } else if (elementName.range(of: "mensaje") != nil) {
            mensaje = ""
        } else if (elementName.range(of: "obtieneVentasPorEmpleadoResponse") != nil) {
            listaRegiones.removeAll()
        } else if (elementName.range(of: "listaVentas") != nil) {
            ventaBean = VentaBean()
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName.range(of: "listaVentas") != nil) {
            listaRegiones.append(ventaBean)
        } else if (elementName.range(of: "obtieneVentasPorEmpleado2Response") != nil) {
            self.alertVentas.dismiss(animated: false, completion: nil)
            
            if codigo == 0 {
                self.tableView.reloadData()
                porcentajeVenta.setProgress(Float(ventaReal) / Float(ventaObjetivo), animated: true);
                porcentajeVentaCircular.setProgress(value: (CGFloat(ventaReal) / CGFloat(ventaObjetivo)) * 100, animationDuration: 2)
                
                if region == 0 && zona == 0 && tienda == 0 {
                    regionHeaderLabel.text = "Región"
                    navBackBoton.isHidden = true
                } else if region > 0 && zona == 0 && tienda == 0 {
                    navBackBoton.isHidden = false
                    regionHeaderLabel.text = "Zona"
                    navBackBoton.setTitle("Regiones", for: UIControlState.normal)
                    nombreUbicacion.text = ubicacion
                } else if region > 0 && zona > 0 && tienda == 0 {
                    navBackBoton.isHidden = false
                    regionHeaderLabel.text = "Tienda"
                    navBackBoton.setTitle("Zonas", for: UIControlState.normal)
                    nombreUbicacion.text = ubicacion
                } else {
                    navBackBoton.isHidden = false
                    regionHeaderLabel.text = "Tienda"
                    navBackBoton.setTitle("Tiendas", for: UIControlState.normal)
                    nombreUbicacion.text = ubicacion
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Error al consultar las ventas: " + mensaje, preferredStyle: UIAlertControllerStyle.alert)
                
                let okAceptar = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    
                    if self.mensaje.contains("no cuenta con tiendas asignadas") {
                        self.salir_();
                    }
                }
                //alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(okAceptar)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        if (!string.isEmpty) {
            if (eName.range(of: "codigo") != nil) {
                codigo = Int(string)!
            } else if (eName.range(of: "mensaje") != nil) {
                mensaje = string
            } else if (eName.range(of: "idElemento") != nil) {
                ventaBean.idElemento = Int(string)!
            } else if (eName.range(of: "nombreElemento") != nil) {
                ventaBean.nombreElemento = string;
            } else if (eName.range(of: "numeroTiendas") != nil) {
                ventaBean.numeroTiendas = Int(string)!
            } else if (eName.range(of: "ticketPromedio") != nil) {
                ventaBean.ticketPromedio = Double(string)!
            } else if (eName.range(of: "ventaObjetivo") != nil) {
                ventaBean.ventaObjetivo = Double(string)!
            } else if (eName.range(of: "ventaPerdida") != nil) {
                ventaBean.ventaPerdida = Double(string)!
            } else if (eName.range(of: "ventaReal") != nil) {
                ventaBean.ventaReal = Double(string)!
            } else if (eName.range(of: "vRealGeneral") != nil) {
                ventaReal = Int64(string)!
                ventaRealLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:ventaReal))!
            } else if (eName.range(of: "vObjetivoGeneral") != nil) {
                ventaObjetivo = Int64(string)!
                if ventaObjetivo >= 1000000 {
                    ventaObjetivoLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:(ventaObjetivo / 1)))!
                    //ventaObjetivoDescLabel.text = "Venta objetivo(mdp)"
                } else {
                    ventaObjetivoLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:(ventaObjetivo / 1)))!
                    //ventaObjetivoDescLabel.text = "Venta objetivo(miles)"
                }
                
            } else if (eName.range(of: "vObjetivoTotal") != nil) {
                ventaObjetivoTotal = Int64(string)!
                vtaObjetivoTotalLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:(ventaObjetivoTotal / 1)))!
                
                /*if ventaObjetivoTotal >= 1000000 {
                    ventaObjetivoTotalLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:(ventaObjetivoTotal / 1)))!
                    //ventaObjetivoDescLabel.text = "Venta objetivo(mdp)"
                } else {
                    ventaObjetivoLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:(ventaObjetivo / 1)))!
                    //ventaObjetivoDescLabel.text = "Venta objetivo(miles)"
                }*/
                
            } else if (eName.range(of: "vPerdidaGeneral") != nil) {
                ventaPerdidaLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:Int64(string)!))!
            } else if (eName.range(of: "tickPromGeneral") != nil) {
                ticketPromedioLabel.text = "$ " + numberFormatter.string(from: NSNumber(value:Int64(string)!))!
            } else if (eName.range(of: "tiendasConVentaGeneral") != nil) {
                tiendasVentaLabel.text = numberFormatter.string(from: NSNumber(value:Int64(string)!))!
            }
            
            if(tipoBusquedaSegue == tipoBusquedaDia) {
                rangoFechasLabel.text = "Consulta al día: " + fechaInicial
                ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA ON"), for: UIControlState.normal)
                ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA OFF"), for: UIControlState.normal)
                ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES OFF"), for: UIControlState.normal)
            } else if(tipoBusquedaSegue == tipoBusquedaSemana) {
                rangoFechasLabel.text = "Consulta del: " + fechaInicial + " al " + fechaFinal
                ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA OFF"), for: UIControlState.normal)
                ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA ON"), for: UIControlState.normal)
                ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES OFF"), for: UIControlState.normal)
            } else {
                rangoFechasLabel.text = "Consulta del: " + fechaInicial + " al " + fechaFinal
                ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA OFF"), for: UIControlState.normal)
                ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA OFF"), for: UIControlState.normal)
                ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES ON"), for: UIControlState.normal)
            }
        }
    }
    
    func limpiaVista() {
        porcentaje = 0.0;
        ventaReal = 0;
        ventaObjetivo = 0;
        ventaObjetivoTotal = 0;
        ventaRealLabel.text = "---"
        ventaObjetivoLabel.text = "---"
        vtaObjetivoTotalLabel.text = "---"
        ventaPerdidaLabel.text = "---"
        ticketPromedioLabel.text = "---"
        tiendasVentaLabel.text = "---"
        rangoFechasLabel.text = "---"
        porcentajeVenta.setProgress(0.0, animated: true);
        porcentajeVentaCircular.setProgress(value: 0.0, animationDuration: 1)
        listaRegiones.removeAll()
        nombreUbicacion.text = ubicacion
        self.tableView.reloadData()
    }
    
    func obtieneFechaPrimerDiaSemanaPorString() -> String {
        let dateFormat = "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: fechaFinal)
        
        let monday1 = getLunes(myDate: date!)
        return dateFormatter.string(from: monday1)
    }
    
    func getLunes(myDate: Date) -> Date {
        /*let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 2 // Monday
        let mondayInWeek = cal.date(from: comps)!
        return mondayInWeek*/
        return myDate.previous(.monday)
    }
    
    func obtieneFechaPrimerDiaMesPorString() -> String {
        let dateFormat = "dd/MM/yyyy"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: fechaFinal)
        return dateFormatter.string(from: (date?.startOfMonth())!)
    }
    
    func obtieneFechaHoy() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    func obtieneFechaPrimerDiaSemana() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date.today().previous(.monday))
    }
    
    func obtieneFechaPrimerDiaMes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date().startOfMonth())
    }
    
    
    //MARK: Actions
    @IBAction func showDirectionPop(_ sender: Any) {
        infoBotonBandera = true;
        let tiendasDisponiblesView =  self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        tiendasDisponiblesView.modalPresentationStyle = UIModalPresentationStyle.popover
        self.present(tiendasDisponiblesView, animated: true, completion: nil)
    }
    
    @IBAction func seleccionaTipoTienda(_ sender: Any) {
        if(tipoTienda == TIPO_TIENDA_ACTIVA) {
            tipoTienda = TIPO_TIENDA_NUEVA
            tipoTiendaBoton.setBackgroundImage(UIImage(named: "carritopuerta_naranja"), for: UIControlState.normal)
        } else if(tipoTienda == TIPO_TIENDA_NUEVA) {
            tipoTienda = TIPO_TIENDA_ACTIVA
            tipoTiendaBoton.setBackgroundImage(UIImage(named: "carritopuerta_azul"), for: UIControlState.normal)
        }
        
        limpiaVista();
        ejecutaWS();
        nombreUbicacion.text = ""
    }
    
    @IBAction func actualizaVentasPorTipo(_ sender: Any) {
        if(banderaFiltro) {
            filtroSinVentasBoton.setBackgroundImage(UIImage(named: "carritoturquesa"), for: UIControlState.normal)
            banderaFiltro = false;
            tipoVenta = TIPO_TIENDA_CON_VENTA;
        } else {
            filtroSinVentasBoton.setBackgroundImage(UIImage(named: "carritonaranja"), for: UIControlState.normal)
            banderaFiltro = true;
            tipoVenta = TIPO_TIENDA_SIN_VENTA;
        }
        limpiaVista();
        ejecutaWS();
    }
    
    @IBAction func actualizaInfoPorPpto(_ sender: Any) {
        if(banderaFiltroPpto) {
            filtroTipoPptoBoton.setBackgroundImage(UIImage(named: "pptoturquesa"), for: UIControlState.normal)
            tipoPpto = TIPO_PPTO_OPERATIVO;
            banderaFiltroPpto = false;
        } else {
            filtroTipoPptoBoton.setBackgroundImage(UIImage(named: "pptonaranja"), for: UIControlState.normal)
            tipoPpto = TIPO_PPTO_FINANZAS;
            banderaFiltroPpto = true;
        }
        limpiaVista();
        ejecutaWS();
    }

    @IBAction func salir(_ sender: Any) {
        salir_();
    }
    
    func salir_() {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        
        let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginPageView, animated: true, completion: nil)
    }
    
    @IBAction func recalculaVentas(_ sender: Any) {
        limpiaVista()
        ejecutaWS()
    }
    
    @IBAction func recalculaVentasHoy(_ sender: Any) {
        tipoBusquedaSegue = tipoBusquedaDia
        ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA ON"), for: UIControlState.normal)
        ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA OFF"), for: UIControlState.normal)
        ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES OFF"), for: UIControlState.normal)
        
        fechaInicial = fechaFinal;
        //fechaFinal = obtieneFechaHoy();
        
        vtaObjetivoTotalLabel.isHidden = true
        vtaObjetivoTotalDescLabel.isHidden = true
        
        ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 355)
        ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 355)
        
        limpiaVista()
        ejecutaWS()
    }
    
    
    @IBAction func recalculaVentasSemana(_ sender: Any) {
        tipoBusquedaSegue = tipoBusquedaSemana
        ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA OFF"), for: UIControlState.normal)
        ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA ON"), for: UIControlState.normal)
        ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES OFF"), for: UIControlState.normal)
        
        /*var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        let weekDay = calendar.component(.weekday, from: Date())
        
        if weekDay == 2 {
            fechaInicial = obtieneFechaHoy()
            fechaFinal = obtieneFechaHoy();
        } else {
            fechaInicial = obtieneFechaPrimerDiaSemana()
            fechaFinal = obtieneFechaHoy();
        }*/
        
        fechaInicial = obtieneFechaPrimerDiaSemanaPorString();
        
        
        vtaObjetivoTotalLabel.isHidden = false
        vtaObjetivoTotalDescLabel.isHidden = false
        
        ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
        ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
        
        limpiaVista()
        ejecutaWS()
    }
    
    
    @IBAction func recalculaVentasMes(_ sender: Any) {
        tipoBusquedaSegue = tipoBusquedaMes
        ventasHoyBoton.setBackgroundImage(UIImage(named: "bts_DIA OFF"), for: UIControlState.normal)
        ventasSemanaBoton.setBackgroundImage(UIImage(named: "bts_SEMANA OFF"), for: UIControlState.normal)
        ventasMesBoton.setBackgroundImage(UIImage(named: "bts_MES ON"), for: UIControlState.normal)
        
        fechaInicial = obtieneFechaPrimerDiaMesPorString()
        //fechaFinal = obtieneFechaHoy()
        
        vtaObjetivoTotalLabel.isHidden = false
        vtaObjetivoTotalDescLabel.isHidden = false
        
        ventaObjetivoLabel.frame.origin = CGPoint(x: 22, y: 336)
        ventaObjetivoDescLabel.frame.origin = CGPoint(x: 213, y: 336)
        
        limpiaVista()
        ejecutaWS()
    }
    
    @IBAction func back(_ sender: Any) {
        banderaUltimoNivel = false;
        /*if(tipoTienda == TIPO_TIENDA_NUEVA || tipoVenta == TIPO_TIENDA_SIN_VENTA) {
            //regionHeaderLabel.text = ""
            //navBackBoton.setTitle("", for: UIControlState.normal)
            //navBackBoton.isHidden = true
            tienda = 0
            ubicacion = ""
            filtroSinVentasBoton.isEnabled = true
            tipoTiendaBoton.isEnabled = true
        } else*/
        if (banderaPorTienda) {
            regionHeaderLabel.text = ""
            navBackBoton.setTitle("", for: UIControlState.normal)
            navBackBoton.isHidden = true
            region = 0
            zona = 0
            tienda = 0
            ubicacion = ""
            banderaPorTienda = false
            filtroSinVentasBoton.isEnabled = true
            tipoTiendaBoton.isEnabled = true
        } else {
            if region > 0 && zona == 0 && tienda == 0 {
                regionHeaderLabel.text = "Región"
                navBackBoton.isHidden = true
                region = 0
                ubicacion = ""
            } else if region > 0 && zona > 0 && tienda == 0 {
                regionHeaderLabel.text = "Zona"
                navBackBoton.setTitle("Regiones", for: UIControlState.normal)
                navBackBoton.isHidden = false
                zona = 0
                ubicacion = ubicacionRegion
            } else if region > 0 && zona > 0 && tienda > 0 {
                regionHeaderLabel.text = "Tienda"
                navBackBoton.setTitle("Zonas", for: UIControlState.normal)
                navBackBoton.isHidden = false
                tienda = 0
                ubicacion = ubicacionRegion + " / " + ubicacionZona
            }
            
            if(tipoTienda == TIPO_TIENDA_NUEVA || tipoVenta == TIPO_TIENDA_SIN_VENTA) {
                tienda = 0;
                ubicacion = "";
            }
            
            if tienda > 0 {
                filtroSinVentasBoton.isEnabled = false
                tipoTiendaBoton.isEnabled = false
            } else {
                filtroSinVentasBoton.isEnabled = true
                tipoTiendaBoton.isEnabled = true
            }
        }
        
        
        
        
        
        //ubicacion = ""
        nombreUbicacion.text = ubicacion
        limpiaVista()
        ejecutaWS()
    }
    
    @IBAction func abreCalendarioPicker(_ sender: Any) {
        let calendarioView =  self.storyboard?.instantiateViewController(withIdentifier: "CalendarioViewController") as! CalendarioViewController
        calendarioView.modalPresentationStyle = UIModalPresentationStyle.currentContext
        calendarioView.usuarioIdSegue = usuarioIdSegue
        calendarioView.tipoBusquedaSegue = tipoBusquedaSegue
        calendarioView.tipoTiendaSegmentedSegue = tipoTienda
        calendarioView.regionSegue = region;
        calendarioView.zonaSegue = zona
        calendarioView.tiendaSegue = tienda
        calendarioView.ubicacion = ubicacion
        self.present(calendarioView, animated: true, completion: nil)
    }
    
    @IBAction func abreTiendasDisponibles(_ sender: Any) {
        let tiendasDisponiblesView =  self.storyboard?.instantiateViewController(withIdentifier: "TiendasViewController") as! TiendasViewController
        tiendasDisponiblesView.modalPresentationStyle = UIModalPresentationStyle.currentContext
        tiendasDisponiblesView.usuarioIdSegue = usuarioIdSegue
        tiendasDisponiblesView.tipoTiendaSegue = TIPO_TIENDA_ACTIVA
        tiendasDisponiblesView.tipoTiendaSegmentedSegue = tipoTienda
        tiendasDisponiblesView.tipoBusquedaSegue = tipoBusquedaSegue
        tiendasDisponiblesView.fechaInicialSegue = fechaInicial
        tiendasDisponiblesView.fechaFinalSegue = fechaFinal
        tiendasDisponiblesView.regionSegue = region;
        tiendasDisponiblesView.zonaSegue = zona
        tiendasDisponiblesView.tiendaSegue = tienda
        tiendasDisponiblesView.ubicacion = ubicacion
        self.present(tiendasDisponiblesView, animated: true, completion: nil)
    }
    
    @IBAction func buscaTiendasNuevas(_ sender: Any) {
        let tiendasDisponiblesView =  self.storyboard?.instantiateViewController(withIdentifier: "TiendasViewController") as! TiendasViewController
        tiendasDisponiblesView.modalPresentationStyle = UIModalPresentationStyle.currentContext
        tiendasDisponiblesView.usuarioIdSegue = usuarioIdSegue
        tiendasDisponiblesView.tipoTiendaSegue = TIPO_TIENDA_NUEVA
        tiendasDisponiblesView.tipoTiendaSegmentedSegue = tipoTienda
        tiendasDisponiblesView.tipoBusquedaSegue = tipoBusquedaSegue
        tiendasDisponiblesView.fechaInicialSegue = fechaInicial
        tiendasDisponiblesView.fechaFinalSegue = fechaFinal
        tiendasDisponiblesView.regionSegue = region;
        tiendasDisponiblesView.zonaSegue = zona
        tiendasDisponiblesView.tiendaSegue = tienda
        self.present(tiendasDisponiblesView, animated: true, completion: nil)
    }
    
    func obtieneUrlPropiedades() -> String {
        guard let plistPath = Bundle.main.path(forResource: "propiedades", ofType: "plist") else { return ""}
        guard let plistData = FileManager.default.contents(atPath: plistPath) else { return ""}
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let  plistDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String : AnyObject] else { return ""}
        
        return (plistDict["URL"] ?? "" as AnyObject) as! String
    }
}

extension Date {
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
}

// MARK: Helper methods
extension Date {
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
}

