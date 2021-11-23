//
//  ViewController.swift
//  MyTask
//
//  Created by Hassnain Khaliq on 22/11/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnDownloadAction(_ sender: UIButton)
    {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DownloadingViewController") as! DownloadingViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnReceiveAction(_ sender: UIButton)
    {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "SendingRecievingViewController") as! SendingRecievingViewController
        controller.senderOrReciever = "Receiver"
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

