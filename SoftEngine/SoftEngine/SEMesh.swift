//
//  SEMesh.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation

class SEMesh {
    var name:String="Mesh";
    var vertices = [Vertex]();
    var faces = [Face]();
    var texture: SETexture?;
    var rotation = SE3DMath.Vector3.Zero();
    var position = SE3DMath.Vector3.Zero();
    var scale = SE3DMath.Vector3.Zero();
    
    init(name:String, verticesCount:Int, facesCount:Int) {
        self.name = name;
        self.vertices = [Vertex]();
        self.faces = [Face]();
        self.texture = nil;
        self.rotation = SE3DMath.Vector3.Zero();
        self.position = SE3DMath.Vector3.Zero();
        self.scale = SE3DMath.Vector3.Zero();
    }
    
    func computeFacesNormal() -> Void {
        for indexFaces in 0 ..< faces.count {
            let currentFace = faces[indexFaces];
            
            let vertexA = vertices[currentFace.A];
            let vertexB = vertices[currentFace.B];
            let vertexC = vertices[currentFace.C];
            
            currentFace.Normal = (vertexA.Normal.add(vertexB.Normal.add(vertexC.Normal))).normalize();
        }
    }
}
