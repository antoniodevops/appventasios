//
//  InfoViewController.swift
//  ReporteVentasNetoiOS
//
//  Created by Antonio Montoya Aguirre on 4/15/19.
//  Copyright © 2019 Antonio Montoya Aguirre. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
