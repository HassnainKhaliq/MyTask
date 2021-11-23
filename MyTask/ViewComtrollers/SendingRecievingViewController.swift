//
//  SendingRecievingViewController.swift
//  MyTask
//
//  Created by Hassnain Khaliq on 23/11/2021.
//

import UIKit
import MultipeerConnectivity

class SendingRecievingViewController: UIViewController{
  
    @IBOutlet weak var lblSending: UILabel!
    @IBOutlet weak var lblReceiving: UILabel!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var viewStack: UIStackView!
    
    
    var imgNo: Int = 0
    var senderOrReciever:String  = ""
    var arrImages = [UIImage]()
    var arrImageViews = [UIImageView]()
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrImageViews = [img1,img2,img3]
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        if(senderOrReciever == "Sender")
        {
            viewStack.isHidden = true
            lblSending.isHidden = false
            //Host a session to send
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "todo")
            advertiser.delegate = self
            advertiser.startAdvertisingPeer()
            
//            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType:  "todo", discoveryInfo: nil, session: self.mcSession)
//            self.mcAdvertiserAssistant.start()
        }
        else
        {
            viewStack.isHidden = false
            lblSending.isHidden = true
            //Host a session to receive
            let mcBrowser = MCBrowserViewController(serviceType: "todo", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }
        
    }
    
    func sendImage(img: UIImage) {
        if mcSession.connectedPeers.count > 0 {
            if let imageData = img.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch let error as NSError {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
}

extension SendingRecievingViewController:  MCSessionDelegate, MCBrowserViewControllerDelegate,MCNearbyServiceAdvertiserDelegate
{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true,mcSession)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            DispatchQueue.main.async {
                self.lblSending.text = "Connected to \(peerID.displayName)"
            }
            
            for img in arrImages
            {
                self.sendImage(img: img)
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.lblReceiving.isHidden = false
                if(self.senderOrReciever == "Receiver")
                {
                    self.lblReceiving.text = "Receiving Images"
                }
                else
                {
                    self.lblReceiving.text = "Sending Images"
                }
            }
        case MCSessionState.connecting:
            DispatchQueue.main.async {
                self.lblSending.text = "Connecting to \(peerID.displayName)"
            }
            

        case MCSessionState.notConnected:
            DispatchQueue.main.async {
                self.lblSending.text = "Disconnected to \(peerID.displayName)"
            }
            

        @unknown default:
            print("unknown status for \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.lblSending.isHidden = false
            self.lblSending.text = "Recieved image No \(self.imgNo + 1)"
        }
        if let image = UIImage(data: data) {
            DispatchQueue.main.async {
                
                self.arrImageViews[self.imgNo].image = image
                self.imgNo += 1
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
        print("Recieved")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
        print("Recieved")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

        print("Recieved")
    }

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
}
