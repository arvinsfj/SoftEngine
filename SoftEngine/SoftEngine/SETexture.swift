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
    var widthf:Float = 0;
    var heightf:Float = 0;
    var internalBuffer:UnsafePointer<UInt8>;
    
    init(fileName:String) {
        self.fileName=fileName;
        
        
        let filePath = Bundle.main.bundlePath + "/\(fileName)";
        let image = UIImage(contentsOfFile: filePath);
        let cgImage = image?.cgImage;
        width=(cgImage?.width)!;
        height=(cgImage?.height)!;
        widthf = Float(width);
        heightf = Float(height);
        let imagedata=malloc(width*height*4);
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let ctx=CGContext(data: imagedata,width: width, height: height, bitsPerComponent: 8, bytesPerRow: self.width*4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue);
        ctx?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: CGFloat(self.width), height: CGFloat(self.height)));
        let imageData = ctx?.data;
        internalBuffer=UnsafePointer<UInt8>(imageData!.assumingMemoryBound(to: UInt8.self));
    }
    
    func map(_ tu:Float, tv:Float) -> SE3DMath.Color4 {
        
        let u = Int(tu * widthf);
        let v = Int(tv * heightf);
        let pos = (u + v * width) << 2;
        let r = Float(internalBuffer[pos]);
        let g = Float(internalBuffer[pos+1]);
        let b = Float(internalBuffer[pos+2]);
        //let a: Float = 255.0;//Float(internalBuffer[pos+3]);
        
        return SE3DMath.Color4(r:r/255.0, g:g/255.0, b:b/255.0, a:1);
    }
}
