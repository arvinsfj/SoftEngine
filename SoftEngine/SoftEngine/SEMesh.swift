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
        for (var indexFaces = 0; indexFaces < self.faces.count; indexFaces++) {
            let currentFace = self.faces[indexFaces];
            
            let vertexA = self.vertices[currentFace.A];
            let vertexB = self.vertices[currentFace.B];
            let vertexC = self.vertices[currentFace.C];
            
            currentFace.Normal = (vertexA.Normal.add(vertexB.Normal.add(vertexC.Normal))).scale(1 / 3);
            currentFace.Normal=currentFace.Normal.normalize();
        }
    }
}
