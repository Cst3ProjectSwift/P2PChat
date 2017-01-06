
//
//  ViewController.swift
//  P2PChat
//
//  Created by Josua von Reding on 28-11-2016.
//  Developed by Josua von Reding and Gian Brun
//  Copyright (c) 2016 Josua von Reding, Gian Brun. All rights reserved
//


import UIKit
import MultipeerConnectivity

class ViewController: UIViewController,  MCSessionDelegate, MCBrowserViewControllerDelegate,UITextFieldDelegate {
    var browserVC:MCBrowserViewController!
    var advertiserAssistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!
    
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatScrollView: UIScrollView!
    
    @IBOutlet weak var sendenButton: UIButton!
    @IBAction func openBrowserButtonClick(_ sender: UIButton) {
        showBrowserVC()
    }
    
    @IBAction func sendButtonClick(){
        self.sendMessage()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMultipeer()
    }
    
    // Textfeld bei Editierung hochfahren
    func textFieldDidBeginEditing(_ sendText: UITextField) {
        chatScrollView.setContentOffset(CGPoint(x: 0, y: 250), animated: true)
    }
    
    
    // MC(Multipeer Connectivity) aufsetzen
    func setUpMultipeer(){
        // Eigene PeerId auf Gerätenamen setzen
        peerID = MCPeerID(displayName: UIDevice.current.name)
        
        // Session erstellen
        session = MCSession(peer: peerID)
        session.delegate = self
        
        // Browser erstellen welcher alle anderen Peers anzeigt
        browserVC = MCBrowserViewController(serviceType: "chat", session: session)
        browserVC.delegate = self
        
        //
        advertiserAssistant = MCAdvertiserAssistant(serviceType: "chat", discoveryInfo: nil, session: session)
        advertiserAssistant.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Sende-Funktion
    func sendMessage(){
        let message:String = self.messageTextField.text!
        self.messageTextField.text = ""
        
        // Nachricht für Übertragung encodieren
        let data :Data = message.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        var error:NSError?
        do {
            try self.session.send(data, toPeers:
                self.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
        } catch let error1 as NSError {
            error = error1
        }
        NSLog("%@", error!)
        self.messageReception(message as NSString, peer: self.peerID)
    }
    
    // Empfangs-Funktion
    func messageReception(_ message:NSString, peer:MCPeerID){
        var finalText:String
        if(peer == self.peerID){
            finalText = "\nIch: \(message)"
        }
        else{
            finalText = "\n\(peer.displayName): \(message)"
        }
        self.chatTextView.text =
            self.chatTextView.text + (finalText as String)
    }
    
    func textFieldShouldReturn(_ sendText: UITextField) -> Bool{
        sendText.resignFirstResponder()
        self.sendMessage()
        return true
    }
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        let message = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        DispatchQueue.main.async(execute: {self.messageReception(message!, peer: peerID)})
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID:MCPeerID){
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?){
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController){
        self.dismissBrowserVC()
    }
    
    // Browser mit verfügenbaren Peers schliessen
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController){
        self.dismissBrowserVC()
    }
    
    // Browser mit verfügbaren Peers anzeigen
    func showBrowserVC(){
        self.present(self.browserVC, animated: true, completion: nil)
    }
    
    func dismissBrowserVC(){
        self.browserVC.dismiss(animated: true, completion: nil) }
    
}
