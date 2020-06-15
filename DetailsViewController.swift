//
//  DetailsViewController.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 15/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import AVKit
import ARKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var descriptionView: UIView!
    private var player: AVPlayer?
        
    @IBAction func viewSinglePainting(_ sender: UIButton) {
        performSegue(withIdentifier: "loadSingleImageinAR", sender: nil)
    }
    
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBAction func audioTapped(_ sender: UIButton) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            player = AVPlayer(url: URL.init(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!)
            
            //This is for a player screen, if you don't want to show a player screen you comment this part
            
            let controller = AVPlayerViewController()
            controller.player = player
            controller.showsPlaybackControls = true
            self.addChild(controller)
            
            let videoFrame = descriptionView.bounds
//            controller.view.frame = videoFrame
            descriptionView.addSubview(controller.view)
            // till here
            
            player?.play()
        } catch {
        }
    }
    
    @IBAction func goBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loadSingleImageinAR") {
            if let destinationVC = segue.destination as? SinglePainitngViewController {
                if let heightStr = heightTextField.text,
                    let widthStr = widthTextField.text {
                    destinationVC.height = Float(heightStr) ?? 0.0
                    destinationVC.width = Float(widthStr) ?? 0.0
                }
            }
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}
