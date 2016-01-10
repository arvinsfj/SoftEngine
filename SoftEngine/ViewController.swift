//
//  ViewController.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var preDate = NSDate();
    var fpsValues = [Int]();
    var fpsLabel = UILabel(frame: CGRectMake(5,20,300,20));
    var canvas = UIImageView();
    var device = SEDevice();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(colorLiteralRed: 2/255.0, green: 88/255.0, blue: 44/255.0, alpha: 1);
        self.view.addSubview(fpsLabel);
        // Do any additional setup after loading the view, typically from a nib.
        canvas.frame=CGRectMake((self.view.frame.size.width-512)/2, (self.view.frame.size.height-384)/2, 512, 384);
        self.view.addSubview(canvas);
        
        self.device = SEDevice(modelFileName: "monkey.babylon", canvas: canvas);
        self.setupDisplayLink();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDisplayLink() -> Void
    {
        let displayLink = CADisplayLink(target: self, selector: Selector("renderLoop"));
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func renderLoop() -> Void
    {
        let nowDate = NSDate();
        let curFPS = Int(1/nowDate.timeIntervalSinceDate(preDate));
        self.preDate = nowDate;
        self.fpsLabel.text = "FPS: \(Int(curFPS))";
        if (self.fpsValues.count<60){
            self.fpsValues.append(curFPS);
        }else{
            self.fpsValues.removeFirst();
            self.fpsValues.append(curFPS);
            var total = 0;
            for value in self.fpsValues {
                total += value;
            }
            if self.fpsValues.count >= 1 {
                let averageFPS = total/self.fpsValues.count;
                self.fpsLabel.text = "FPS: \(Int(curFPS))  AFPS: \(averageFPS)";
            }
        }
        
        device.clear();
        device.update();
        device.render();
        device.show();
    }
}

