//
//  SETexture.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation
import UIKit

class SETexture {
    var fileName:String = "";
    var width:Int = 0;
    var height:Int = 0;
    var internalBuffer:UnsafePointer<UInt8>? = nil;
    
    init(fileName:String, width:Int, height:Int) {
        self.fileName=fileName;
        self.width=width;
        self.height=height;
        self.load(self.fileName);
    }
    
    private func load(fileName:String) -> Void {
        let filePath:String=NSBundle.mainBundle().bundlePath.stringByAppendingString("/\(fileName)");
        let image=UIImage(contentsOfFile: filePath);
        let cgImage = image?.CGImage;
        self.width=CGImageGetWidth(cgImage);
        self.height=CGImageGetHeight(cgImage);
        let imagedata=malloc(self.width*self.height*4);
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        let ctx=CGBitmapContextCreate(imagedata,self.width,self.height,8,self.width*4,CGColorSpaceCreateDeviceRGB(),bitmapInfo.rawValue);
        CGContextDrawImage(ctx, CGRectMake(0, 0, CGFloat(self.width), CGFloat(self.height)), cgImage);
        let imageData = CGBitmapContextGetData(ctx);
        self.internalBuffer=UnsafePointer<UInt8>(imageData);
    }
    
    func map(tu:Float, tv:Float) -> SE3DMath.Color4 {
        
        if let buf = self.internalBuffer {
            let u = Int(abs(tu * Float(self.width))) % self.width;
            let v = Int(abs(tv * Float(self.height))) % self.height;
            var pos = (u + v * self.width) << 2;
            let r = Float(buf[pos++]);
            let g = Float(buf[pos++]);
            let b = Float(buf[pos++]);
            let a = Float(buf[pos]);
            
            return SE3DMath.Color4(r:r/255.0, g:g/255.0, b:b/255.0, a:a/255.0);
        }
        return SE3DMath.Color4(r:1, g:1, b:1, a:1);
    }
}
