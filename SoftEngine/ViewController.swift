//
//  ViewController.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var preDate = Date();
    var fpsValues = [Int]();
    var fpsLabel = UILabel(frame:CGRect(x: 5,y: 20,width: 300,height: 20));
    var canvas = UIImageView();
    var canvasAscii = UILabel();
    let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedLast.rawValue);
    var device = SEDevice();
    
    var rx:Float = 0.0;
    var ry:Float = 0.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;//UIColor(colorLiteralRed: 2/255.0, green: 88/255.0, blue: 44/255.0, alpha: 1);
        //self.view.addSubview(fpsLabel);
        
        // Do any additional setup after loading the view, typically from a nib.
        canvas.frame=CGRect(x: (self.view.frame.size.width-330)/2, y: 0, width: 330, height: 330);
        canvas.backgroundColor = UIColor.lightGray;
        self.view.addSubview(canvas);
        canvasAscii.frame=CGRect(x: (self.view.frame.size.width-330)/2, y: 330-(412-334)/2, width: 330, height: 412);
        canvasAscii.font = UIFont.init(name: "Inziu-Iosevka-CL-Regular", size: 1.0);//等宽字体
        canvasAscii.numberOfLines = 0;
        self.view.addSubview(canvasAscii);
        
        self.view.bringSubview(toFront: canvas);
        
        //monkey.babylon//ring.babylon//cylinder.babylon
        self.device = SEDevice(modelFileName: "monkey.babylon");
        self.setupDisplayLink();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDisplayLink() -> Void
    {
        let displayLink = CADisplayLink(target: self, selector: #selector(self.renderLoop));
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    func renderLoop() -> Void
    {
        let nowDate = Date();
        let curFPS = Int(1/nowDate.timeIntervalSince(preDate));
        self.preDate = nowDate;
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
                self.fpsLabel.text = "APS: \(averageFPS)   FPS: \(curFPS)";
            }
        }
        
        device.clear();
        device.update(){ meshes in
            for i in 0 ..< meshes.count {
                meshes[i].rotation.x += -ry;
                meshes[i].rotation.y += -rx;
            }
            rx = 0.08;
            //rx = 0;
            ry = 0;
        };
        device.show(){ data in
            let ctx = CGContext(data: UnsafeMutableRawPointer(mutating: data), width: 330, height: 330, bitsPerComponent: 8, bytesPerRow: 330*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: self.bitmapInfo.rawValue);
            let imageRef = ctx?.makeImage();
            self.canvas.layer.contents = imageRef;
        };
        device.showAscii(){ str in
            self.canvasAscii.text = str;
        };
    }
    
    var startPoint:CGPoint = CGPointFromString("0");
    var endPoint:CGPoint = CGPointFromString("0");
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        let start = touches.first;
        startPoint = start!.location(in: self.view);
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        let end = touches.first;
        endPoint = end!.location(in: self.view);
        
        let ddx = endPoint.x - startPoint.x;
        let ddy = endPoint.y - startPoint.y;
        
        rx = Float(ddx) / Float(self.view.frame.size.width);
        ry = Float(ddy) / Float(self.view.frame.size.height);

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        rx = 0;
        ry = 0;
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        rx = 0;
        ry = 0;
    }
}

