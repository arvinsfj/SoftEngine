//
//  SECamera.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation

class SECamera {
    var position:SE3DMath.Vector3=SE3DMath.Vector3.Zero();
    var target:SE3DMath.Vector3=SE3DMath.Vector3.Zero();
    
    init(position:SE3DMath.Vector3, target:SE3DMath.Vector3) {
        self.position=position;
        self.target=target;
    }
}
