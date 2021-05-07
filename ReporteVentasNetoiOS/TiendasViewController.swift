//
//  TiendasViewController.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 23/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit
import Alamofire

class TiendasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, NSURLConnectionDelegate,NSURLConnectionDataDelegate,  XMLParserDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let alertVentas = UIAlertController(title: nil, message: "Buscando tiendas", preferredStyle: .alert)
    let searchController = UISearchController(searchResultsController: nil)
    
    var eName: String = String()
    var codigo = Int();
    var mensaje = String();
    var listaTiendasFiltradas: Array<TiendaBean> = Array()
    var listaTiendas: Array<TiendaBean> = Array()
    var tiendaBean = TiendaBean();

    var usuarioIdSegue = Int()
    var tipoBusquedaSegue = Int()
    var fechaInicialSegue = String()
    var fechaFinalSegue = String()
    var regionSegue = Int();
    var zonaSegue = Int();
    var tiendaSegue = Int();
    var tipoTiendaSegue = Int();
    var tipoTiendaSegmentedSegue = Int();
    var ubicacion = String();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.tintColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        searchController.searchBar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        
        //ejecutaWS()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*alertVentas.view.tintColor = UIColor.black
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alertVentas.view.addSubview(loadingIndicator)
        present(alertVentas, animated: true, completion: nil)*/
        ejecutaWS()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaTiendasFiltradas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TiendaDisponibleCell", for: indexPath) as! TiendaDisponibleViewCell
        
        cell.numeroTienda.text = String(listaTiendasFiltradas[indexPath.row].idTienda)
        cell.nombreTienda.text = listaTiendasFiltradas[indexPath.row].nombreTienda
        
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == "" {
            listaTiendasFiltradas = listaTiendas
        } else {
            // Filter the results
            listaTiendasFiltradas = listaTiendas.filter { $0.nombreTienda.lowercased().contains(searchController.searchBar.text!.lowercased()) || String($0.idTienda).lowercased().contains(searchController.searchBar.text!.lowercased())}
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let principalView = self.storyboard?.instantiateViewController(withIdentifier: "VistaRegionesView") as! ViewController
        
        NSLog("*** INDEXPATH ")
        NSLog(String(indexPath.row))
        NSLog(String(listaTiendasFiltradas.count))
        
        principalView.esPopVistaSegue = false
        principalView.usuarioIdSegue = usuarioIdSegue
        principalView.tipoTiendaSegue = tipoTiendaSegue
        principalView.tipoBusquedaSegue = tipoBusquedaSegue
        principalView.fechaInicial = fechaInicialSegue
        principalView.fechaFinal = fechaFinalSegue
        principalView.region = listaTiendasFiltradas[indexPath.row].idRegion
        principalView.zona = listaTiendasFiltradas[indexPath.row].idZona
        principalView.tienda = listaTiendasFiltradas[indexPath.row].idTienda
        principalView.ubicacion = listaTiendasFiltradas[indexPath.row].nombreRegion + " / " + listaTiendasFiltradas[indexPath.row].nombreZona +
            " / " + listaTiendasFiltradas[indexPath.row].nombreTienda
        principalView.tipoTiendaSegmentedSegue = tipoTiendaSegmentedSegue
        principalView.infoBotonBandera = true;
        //self.dismiss(animated: true, completion: nil)
        principalView.actualizaConsultaPorTienda()
        
        searchController.isActive = false
        self.tableView.reloadData()
        
        
        self.present(principalView, animated: true, completion: nil)
    }
    
    func ejecutaWS() {
        
        alertVentas.view.tintColor = UIColor.black
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alertVentas.view.addSubview(loadingIndicator)
        self.present(alertVentas, animated: true, completion: nil)
        //self.view.addSubview(alertVentas.view)
        
        //Make the request
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = TimeInterval(30)
        configuration.timeoutIntervalForRequest = TimeInterval(30)
        _ = Alamofire.SessionManager(configuration: configuration)
        
        NSLog("*** tipoTienda: \(tipoTiendaSegue)")
        
        let parameters: Parameters = [
            "numeroEmpleado": usuarioIdSegue,
            "tipoTienda": tipoTiendaSegue
        ]
        
        Alamofire.request(obtieneUrlPropiedades() + "obtieneTiendasPorEmpleado",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding(destination: .queryString)).validate(statusCode: 200..<300).responseString {
                            
                response in //debugPrint(response.result.value!)
                            
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
        } else if (elementName.range(of: "obtieneTiendasPorEmpleadoResponse") != nil) {
            listaTiendas.removeAll()
        } else if (elementName.range(of: "listaTiendas") != nil) {
            tiendaBean = TiendaBean()
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName.range(of: "listaTiendas") != nil) {
            listaTiendas.append(tiendaBean)
        } else if (elementName.range(of: "obtieneTiendasPorEmpleadoResponse") != nil) {
            self.alertVentas.dismiss(animated: false, completion: nil)
            
            if codigo == 0 {
                listaTiendasFiltradas = listaTiendas
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Error al consultar las tiendas: " + mensaje, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
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
            } else if (eName.range(of: "idPais") != nil) {
                tiendaBean.idPais = Int(string)!
            } else if (eName.range(of: "idRegion") != nil) {
                tiendaBean.idRegion = Int(string)!;
            } else if (eName.range(of: "idZona") != nil) {
                tiendaBean.idZona = Int(string)!
            } else if (eName.range(of: "idTienda") != nil) {
                tiendaBean.idTienda = Int(string)!
            } else if (eName.range(of: "nombreTienda") != nil) {
                tiendaBean.nombreTienda = string
            } else if (eName.range(of: "nombreRegion") != nil) {
                tiendaBean.nombreRegion = string
            } else if (eName.range(of: "nombreZona") != nil) {
                tiendaBean.nombreZona = string
            }
            
        }
    }

    
    @IBAction func back(_ sender: Any) {
        searchController.searchBar.endEditing(true)
        searchController.searchBar.resignFirstResponder()
        let principalView = self.storyboard?.instantiateViewController(withIdentifier: "VistaRegionesView") as! ViewController
        principalView.esPopVistaSegue = false
        principalView.usuarioIdSegue = usuarioIdSegue
        principalView.tipoTiendaSegue = tipoTiendaSegue
        principalView.tipoBusquedaSegue = tipoBusquedaSegue
        principalView.fechaInicial = fechaInicialSegue
        principalView.fechaFinal = fechaFinalSegue
        principalView.region = regionSegue
        principalView.zona = zonaSegue
        principalView.tienda = tiendaSegue
        principalView.actualizaConsultaPorTienda()
        principalView.ubicacion = ubicacion
        self.present(principalView, animated: true, completion: nil)
    }
    
    func obtieneUrlPropiedades() -> String {
        guard let plistPath = Bundle.main.path(forResource: "propiedades", ofType: "plist") else { return ""}
        guard let plistData = FileManager.default.contents(atPath: plistPath) else { return ""}
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let  plistDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String : AnyObject] else { return ""}
        
        return (plistDict["URL"] ?? "" as AnyObject) as! String
    }
}
