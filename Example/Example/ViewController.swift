//
//  ViewController.swift
//  MultiPicker
//
//  Created by Bell App Lab on 10/30/2015.
//  Copyright (c) 2015 Bell App Lab. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, MultiPickerable {
    
    @IBOutlet weak var programmaticallyModalButton: UIButton!
    @IBOutlet weak var programmaticallyPopoverButton: UIButton!
    @IBOutlet weak var modalSegueButton: UIButton!
    @IBOutlet weak var popoverSegueButton: UIButton!
    @IBOutlet weak var embededSegueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.programmaticallyModalButton.addTarget(self, action: "programmaticallyPressed:", forControlEvents: .TouchUpInside)
        self.programmaticallyPopoverButton.addTarget(self, action: "programmaticallyPressed:", forControlEvents: .TouchUpInside)
        
        self.programmaticallyPopoverButton.enabled = UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    @IBAction func programmaticallyPressed(sender: UIButton) {
        if sender == self.programmaticallyModalButton {
            if let controller = MultiPicker.make(self) {
                self.presentViewController(controller, animated: true, completion: nil)
            }
        } else if sender == self.programmaticallyPopoverButton {
            if let controller = MultiPicker.make(self) {
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let picker = segue.destinationViewController as? MultiPicker {
            picker.able = self
        }
    }
    
    //MARK: MultiPickerable
    func didFinish(multiPicker: MultiPicker) {
        print("These are the selected assets: \(multiPicker.picked)")
    }
}

class SecondViewController: UIViewController, MultiPickerable {
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let picker = segue.destinationViewController as? MultiPicker {
            picker.able = self
            self.countLabel.text = "\(picker.picked.count)"
        }
    }
    
    //MARK: MultiPickerable
    @objc func multi(picker: MultiPicker, didSelect asset: PHAsset, atIndex index: Int) {
        self.countLabel.text = "\(picker.picked.count)"
    }
    
    @objc func multi(picker: MultiPicker, didDeselect asset: PHAsset, atIndex index: Int) {
        self.countLabel.text = "\(picker.picked.count)"
    }
    
    @objc func didClear(multiPicker: MultiPicker) {
        self.countLabel.text = "\(multiPicker.picked.count)"
    }
    
    @objc func didFinish(multiPicker: MultiPicker) {
        //Noop
    }
}

