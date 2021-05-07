//
//  LoginViewController.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 20/02/18.
//  Copyright © 2018 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, XMLParserDelegate, UITextFieldDelegate {
    
    //MARK: Properties

    @IBOutlet weak var usuario: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //MARK: Constantes
    
    let alertVentas = UIAlertController(title: nil, message: "Validando usuario", preferredStyle: .alert)
    let ID_APP = Int(4);
    
    //MARK: Variables
    
    var eName: String = String()
    var codigo = Int();
    var mensaje = String();
    var usuarioBean = UsuarioBean()
    var URL_WSDL = String();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.usuario.delegate = self;
        self.password.delegate = self;
        self.usuario.attributedPlaceholder = NSAttributedString(string: "  Usuario",
                                                                attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.0)])
        self.password.attributedPlaceholder = NSAttributedString(string: "  Contraseña",
                                                                attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.0)])
        
        /*let userLoginStatus = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        let userLogin = UserDefaults.standard.integer(forKey: "usuarioId")
        
        if(userLoginStatus) {
            NSLog("*** YA SE LOGUEO ***")
            let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "VistaRegionesView") as! ViewController
            loginPageView.usuarioIdSegue = userLogin
            self.present(loginPageView, animated: true, completion: nil)
        } else {
            NSLog("*** NO SE LOGUEADO ***")
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userLoginStatus = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        let userLogin = UserDefaults.standard.integer(forKey: "usuarioId")
        
        if(userLoginStatus) {
            NSLog("*** YA SE LOGUEO ***")
            let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "VistaRegionesView") as! ViewController
            loginPageView.usuarioIdSegue = userLogin
            self.present(loginPageView, animated: true, completion: nil)
        } else {
            NSLog("*** NO SE LOGUEADO ***")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 20
    }

    //MARK: Actions
    
    @IBAction func validaUsuario(_ sender: Any) {
        NSLog("**** 1 *****")
        if usuario.text == "" {
            let alert = UIAlertController(title: "Espera un momento", message: "Introducir un número de usuario", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if password.text == "" {
            let alert = UIAlertController(title: "Espera un momento", message: "Introducir una contraseña", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            NSLog("**** 2 *****")
            ejecutaWS()
        }
        
        
    }
    
    func ejecutaWS() {
        
        alertVentas.view.tintColor = UIColor.black
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alertVentas.view.addSubview(loadingIndicator)
        present(alertVentas, animated: true, completion: nil)
        
        let passMd5 = MD5(string: password.text!)
        let passMd5Hex =  passMd5.map { String(format: "%02hhx", $0) }.joined()
        
        
        //Make the request
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = TimeInterval(30)
        configuration.timeoutIntervalForRequest = TimeInterval(30)
        _ = Alamofire.SessionManager(configuration: configuration)
        
        let parameters: Parameters = [
            "usuario": usuario.text ?? "",
            "password": passMd5Hex,
            "idApp": ID_APP
        ]
        
        NSLog("Pass \(passMd5Hex)");
        
        NSLog("**** 3 *****")
        
        //Alamofire.request("https://www.servicios.tiendasneto.com/WSSIANMoviles/services/WSRutasMovil/validaUsuario",
        Alamofire.request(obtieneUrlPropiedades() + "validaUsuario",
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
                                NSLog("**** 4 *****")
                                break
                            case .failure(let error):
                                // failure...
                                self.alertVentas.dismiss(animated: false, completion: nil)
                                
                                let alert = UIAlertController(title: "Error", message: "Error en la comunicación con el servicio: " + error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                
                                // Create the actions
                                alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                                NSLog("**** 5 *****")
                                break
                            }
                            
                            
        }
    }
    
    func obtieneUrlPropiedades() -> String {
        guard let plistPath = Bundle.main.path(forResource: "propiedades", ofType: "plist") else { return ""}
        guard let plistData = FileManager.default.contents(atPath: plistPath) else { return ""}
        
        var format = PropertyListSerialization.PropertyListFormat.xml
        guard let  plistDict = try! PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String : AnyObject] else { return ""}
        
        return (plistDict["URL"] ?? "" as AnyObject) as! String
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        
        if (elementName.range(of: "codigo") != nil) {
            codigo = 0
        } else if (elementName.range(of: "mensaje") != nil) {
            mensaje = ""
        } else if (elementName.range(of: "validaUsuarioResponse") != nil) {
            usuarioBean = UsuarioBean()
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName.range(of: "validaUsuarioResponse") != nil) {
            self.alertVentas.dismiss(animated: false, completion: {() -> Void in
                if self.codigo == 0 && self.usuarioBean.esUsuarioValido {
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    UserDefaults.standard.set(self.usuarioBean.usuarioId, forKey: "usuarioId")
                    UserDefaults.standard.synchronize()
                    
                    let loginPageView =  self.storyboard?.instantiateViewController(withIdentifier: "VistaRegionesView") as! ViewController
                    loginPageView.usuarioIdSegue = self.usuarioBean.usuarioId
                    self.present(loginPageView, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: self.mensaje, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
            
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
            } else if (eName.range(of: "esUsuarioValido") != nil) {
                if string.range(of: "false") != nil {
                    usuarioBean.esUsuarioValido = false
                } else if string.range(of: "true") != nil {
                    usuarioBean.esUsuarioValido = true
                }
            } else if (eName.range(of: "nombreUsuario") != nil) {
                usuarioBean.nombreUsuario = string;
                usuarioBean.usuarioId = Int(usuario.text!)!
            }
            
        }
    }
    
    func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    
}
