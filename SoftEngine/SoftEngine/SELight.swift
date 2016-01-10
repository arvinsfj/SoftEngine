//
//  SELight.swift
//  SoftEngine
//
//  Created by cz on 12/18/15.
//  Copyright © 2015 cz. All rights reserved.
//

import UIKit

class SELight {
    var position:SE3DMath.Vector3=SE3DMath.Vector3.Zero();
    var color:SE3DMath.Color4=SE3DMath.Color4.Default();
    
    init(position:SE3DMath.Vector3, color:SE3DMath.Color4) {
        self.position=position;
        self.color=color;
    }
}
