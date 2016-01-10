//
//  SEData.swift
//  SoftEngine
//
//  Created by cz on 12/18/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit

class SEData {
    var curY:Float = 0.0;
    
    var ndotla:Float = 0.0;
    var ndotlb:Float = 0.0;
    var ndotlc:Float = 0.0;
    var ndotld:Float = 0.0;
    
    var ua:Float = 0.0;
    var ub:Float = 0.0;
    var uc:Float = 0.0;
    var ud:Float = 0.0;
    
    var va:Float = 0.0;
    var vb:Float = 0.0;
    var vc:Float = 0.0;
    var vd:Float = 0.0;
    
    init(){}
    
    init(curY:Float, ndotla:Float, ndotlb:Float, ndotlc:Float, ndotld:Float, ua:Float, ub:Float, uc:Float, ud:Float, va:Float, vb:Float, vc:Float, vd:Float)
    {
        self.curY=curY;
        self.ndotla=ndotla;
        self.ndotlb=ndotlb;
        self.ndotlc=ndotlc;
        self.ndotld=ndotld;
        self.ua=ua;
        self.ub=ub;
        self.uc=uc;
        self.ud=ud;
        self.va=va;
        self.vb=vb;
        self.vc=vc;
        self.vd=vd;
    }
}
