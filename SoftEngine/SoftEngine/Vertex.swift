//
//  Vertex.swift
//  SoftEngine
//
//  Created by cz on 12/18/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation

class Vertex {
    var Coordinate:SE3DMath.Vector3 = SE3DMath.Vector3.Zero();
    var WorldCoordinate:SE3DMath.Vector3 = SE3DMath.Vector3.Zero();
    var TextureCoordinate:SE3DMath.Vector2 = SE3DMath.Vector2.Zero();
    var Normal:SE3DMath.Vector3 = SE3DMath.Vector3.Zero();
    
    init(){}
    
    init(Coordinate:SE3DMath.Vector3, WorldCoordinate:SE3DMath.Vector3, TextureCoordinate:SE3DMath.Vector2, Normal:SE3DMath.Vector3)
    {
        self.Coordinate=Coordinate;
        self.WorldCoordinate=WorldCoordinate;
        self.TextureCoordinate=TextureCoordinate;
        self.Normal=Normal;
    }
}
