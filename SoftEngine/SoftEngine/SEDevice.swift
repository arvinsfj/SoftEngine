//
//  SEDevice.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation
import UIKit

class SEDevice {
    private var defaultMeshes = [SEMesh]();
    private var defaultCamera = SECamera(position: SE3DMath.Vector3(x:0,y:0,z:10),target: SE3DMath.Vector3(x:0,y:0,z:0));
    private var defaultLight = SELight(position: SE3DMath.Vector3(x:0,y:0,z:10),color:SE3DMath.Color4(r: 1, g: 1, b: 1, a: 1));
    
    var workingWidth = 512;
    var workingHeight = 384;
    var backBuffer = [UInt8](count: 512*384*4, repeatedValue: 0);
    var workingContext = UIImageView();
    var depthBuffer = [Float](count: 512*384, repeatedValue: 10000000);
    
    init(){}
    
    init(modelFileName:String, canvas:UIImageView){
        let filePath:String=NSBundle.mainBundle().bundlePath.stringByAppendingString("/\(modelFileName)");
        let jsonData=NSData(contentsOfFile: filePath)!;
        self.workingContext = canvas;
        self.defaultMeshes = self.createMeshesFromJSON(jsonData);
    }
    
    func clear() -> Void {//59 fps
        self.backBuffer = [UInt8](count: 512*384*4, repeatedValue: 0);
        self.depthBuffer = [Float](count: 512*384, repeatedValue: 10000000);
    }
    
    func update() -> Void {//59 fps
        for i in 0 ..< self.defaultMeshes.count {
            //self.defaultMeshes[i].rotation.x += 0.05;
            self.defaultMeshes[i].rotation.y += 0.05;
        }
    }
    
    func render() -> Void {//30 fps
        self.render(self.defaultCamera, light: self.defaultLight, meshes: self.defaultMeshes)
    }
    
    func show() -> Void {//59 fps
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue);
        let ctx = CGBitmapContextCreate(UnsafeMutablePointer<Void>(self.backBuffer), 512, 384, 8, 512*4, CGColorSpaceCreateDeviceRGB(), bitmapInfo.rawValue);
        let imageRef = CGBitmapContextCreateImage(ctx);
        self.workingContext.layer.contents = imageRef;
    }
    
    //
/*
    private func putPixel(x:Float, y:Float, z:Float, color:SE3DMath.Color4) -> Void {
        let index = Int((x) + (y) * Float(self.workingWidth));
        if (self.depthBuffer[index] >= z) {
            self.depthBuffer[index] = z;
            var index4 = index << 2;
            self.backBuffer[index4++] = UInt8(color.r * 255);
            self.backBuffer[index4++] = UInt8(color.g * 255);
            self.backBuffer[index4++] = UInt8(color.b * 255);
            self.backBuffer[index4++] = UInt8(color.a * 255);
        }
    }
    
    private func drawPoint(point:SE3DMath.Vector3, color:SE3DMath.Color4) -> Void
    {
        if (point.x >= 0 && point.y >= 0 && point.x < Float(self.workingWidth) && point.y < Float(self.workingHeight))
        {
            self.putPixel(point.x, y: point.y, z: point.z, color: color);
        }
    }
*/
    
    private func project(vertex:Vertex, transMatrix:SE3DMath.Matrix, worldMatrix:SE3DMath.Matrix) -> Vertex {
        let point2d = vertex.Coordinate.transformPoint(transMatrix);
        let point3DWorld = vertex.Coordinate.transformPoint(worldMatrix);
        let normal3DWorld = vertex.Normal.transformPoint(worldMatrix);
        let x = point2d.x * Float(self.workingWidth) + Float(self.workingWidth) / 2.0;
        let y = -point2d.y * Float(self.workingHeight) + Float(self.workingHeight) / 2.0;
        return Vertex(Coordinate: SE3DMath.Vector3(x: x, y: y, z: point2d.z), WorldCoordinate: point3DWorld, TextureCoordinate: vertex.TextureCoordinate, Normal: normal3DWorld);
    }
    
    private func computeNDotL(pointPos:SE3DMath.Vector3, var normal:SE3DMath.Vector3, lightPos:SE3DMath.Vector3) -> Float
    {
        var lightDir = lightPos.sub(pointPos);
        normal=normal.normalize();
        lightDir=lightDir.normalize();
        return max(0, normal.dot(lightDir));
    }
    
    private func clamp(value:Float, minValue:Float = 0 , maxValue:Float = 1) -> Float {
        return max(minValue, min(value, maxValue));
    }
    
    private func interpolate(minValue:Float = 0, maxValue:Float = 1, gradient:Float) -> Float {
        return minValue + (maxValue - minValue) * gradient;//self.clamp(gradient);
    }
    
    private func processScanLine(data:SEData, va:Vertex, vb:Vertex, vc:Vertex, vd:Vertex, color:SE3DMath.Color4, texture:SETexture?) -> Void
    {
        let pa = va.Coordinate;
        let pb = vb.Coordinate;
        let pc = vc.Coordinate;
        let pd = vd.Coordinate;
        
        let gradient1 = pa.y != pb.y ? (data.curY - pa.y) / (pb.y - pa.y) : 1;
        let gradient2 = pc.y != pd.y ? (data.curY - pc.y) / (pd.y - pc.y) : 1;
        
        let sx = interpolate(pa.x, maxValue: pb.x, gradient: gradient1);
        let ex = interpolate(pc.x, maxValue: pd.x, gradient: gradient2);
        
        let z1 = interpolate(pa.z, maxValue: pb.z, gradient: gradient1);
        let z2 = interpolate(pc.z, maxValue: pd.z, gradient: gradient2);
        
        let snl = interpolate(data.ndotla, maxValue: data.ndotlb, gradient: gradient1);
        let enl = interpolate(data.ndotlc, maxValue: data.ndotld, gradient: gradient2);
        
        //55 fps
        let xend = Float(Int(ex));
        let xlen = ex - sx;
        let curY = data.curY;
        let cury = Int(curY) * workingWidth;
        for (var x = sx; x < xend; x++)
        {
            if (x >= 0 && curY >= 0 && x < Float(workingWidth) && data.curY < Float(workingHeight))
            {
                let gradient = (x - sx) / xlen;
                let z = interpolate(z1, maxValue: z2, gradient: gradient);
                let index = Int(x) + cury;
                if (z < depthBuffer[index]) {
                    depthBuffer[index] = z;
                    let ndotl = interpolate(snl, maxValue: enl, gradient: gradient);
                    var index4 = index << 2;
                    if let tex = texture {
                        let su = interpolate(data.ua, maxValue: data.ub, gradient: gradient1);
                        let eu = interpolate(data.uc, maxValue: data.ud, gradient: gradient2);
                        let sv = interpolate(data.va, maxValue: data.vb, gradient: gradient1);
                        let ev = interpolate(data.vc, maxValue: data.vd, gradient: gradient2);
                        let u = interpolate(su, maxValue: eu, gradient: gradient);
                        let v = interpolate(sv, maxValue: ev, gradient: gradient);
                        let texColor = tex.map(u, tv: v);
                        backBuffer[index4++] = UInt8(color.r * ndotl * texColor.r * 255);
                        backBuffer[index4++] = UInt8(color.g * ndotl * texColor.g * 255);
                        backBuffer[index4++] = UInt8(color.b * ndotl * texColor.b * 255);
                        backBuffer[index4] = 255;
                    }else{
                        backBuffer[index4++] = UInt8(color.r * ndotl * 255);
                        backBuffer[index4++] = UInt8(color.g * ndotl * 255);
                        backBuffer[index4++] = UInt8(color.b * ndotl * 255);
                        backBuffer[index4] = 255;
                    }
                }
            }
        }
    }
    
    private func drawTriangle(var v1:Vertex, var v2:Vertex, var v3:Vertex, color:SE3DMath.Color4, lightPos:SE3DMath.Vector3, texture:SETexture?) -> Void
    {
        if (v1.Coordinate.y > v2.Coordinate.y) {
            let temp = v2;
            v2 = v1;
            v1 = temp;
        }
        
        if (v2.Coordinate.y > v3.Coordinate.y) {
            let temp = v2;
            v2 = v3;
            v3 = temp;
        }
        
        if (v1.Coordinate.y > v2.Coordinate.y) {
            let temp = v2;
            v2 = v1;
            v1 = temp;
        }
        
        let p1 = v1.Coordinate;
        let p2 = v2.Coordinate;
        let p3 = v3.Coordinate;
        
        let nl1 = self.computeNDotL(v1.WorldCoordinate, normal: v1.Normal, lightPos: lightPos);
        let nl2 = self.computeNDotL(v2.WorldCoordinate, normal: v2.Normal, lightPos: lightPos);
        let nl3 = self.computeNDotL(v3.WorldCoordinate, normal: v3.Normal, lightPos: lightPos);
        
        let data = SEData();
        
        var dP1P2:Float;
        var dP1P3:Float;
        
        if (p2.y > p1.y){
            dP1P2 = (p2.x - p1.x) / (p2.y - p1.y);
        } else {
            dP1P2 = 0;
        }
        
        if (p3.y > p1.y){
            dP1P3 = (p3.x - p1.x) / (p3.y - p1.y);
        } else {
            dP1P3 = 0;
        }
        
        if (dP1P2 > dP1P3) {
            for (var y = Int(p1.y); y <= Int(p3.y); y++) {
                data.curY = Float(y);
                
                if (Float(y) < p2.y) {
                    data.ndotla = nl1;
                    data.ndotlb = nl3;
                    data.ndotlc = nl1;
                    data.ndotld = nl2;
                    
                    data.ua = v1.TextureCoordinate.x;
                    data.ub = v3.TextureCoordinate.x;
                    data.uc = v1.TextureCoordinate.x;
                    data.ud = v2.TextureCoordinate.x;
                    
                    data.va = v1.TextureCoordinate.y;
                    data.vb = v3.TextureCoordinate.y;
                    data.vc = v1.TextureCoordinate.y;
                    data.vd = v2.TextureCoordinate.y;
                    
                    self.processScanLine(data, va: v1, vb: v3, vc: v1, vd: v2, color: color, texture: texture);
                } else {
                    data.ndotla = nl1;
                    data.ndotlb = nl3;
                    data.ndotlc = nl2;
                    data.ndotld = nl3;
                    
                    data.ua = v1.TextureCoordinate.x;
                    data.ub = v3.TextureCoordinate.x;
                    data.uc = v2.TextureCoordinate.x;
                    data.ud = v3.TextureCoordinate.x;
                    
                    data.va = v1.TextureCoordinate.y;
                    data.vb = v3.TextureCoordinate.y;
                    data.vc = v2.TextureCoordinate.y;
                    data.vd = v3.TextureCoordinate.y;
                    
                    self.processScanLine(data, va: v1, vb: v3, vc: v2, vd: v3, color: color, texture: texture);
                }
            }
        } else {
            for (var y = Int(p1.y); y <= Int(p3.y); y++) {
                data.curY = Float(y);
                
                if (Float(y) < p2.y) {
                    data.ndotla = nl1;
                    data.ndotlb = nl2;
                    data.ndotlc = nl1;
                    data.ndotld = nl3;
                    
                    data.ua = v1.TextureCoordinate.x;
                    data.ub = v2.TextureCoordinate.x;
                    data.uc = v1.TextureCoordinate.x;
                    data.ud = v3.TextureCoordinate.x;
                    
                    data.va = v1.TextureCoordinate.y;
                    data.vb = v2.TextureCoordinate.y;
                    data.vc = v1.TextureCoordinate.y;
                    data.vd = v3.TextureCoordinate.y;
                    
                    self.processScanLine(data, va: v1, vb: v2, vc: v1, vd: v3, color: color, texture: texture);
                } else {
                    data.ndotla = nl2;
                    data.ndotlb = nl3;
                    data.ndotlc = nl1;
                    data.ndotld = nl3;
                    
                    data.ua = v2.TextureCoordinate.x;
                    data.ub = v3.TextureCoordinate.x;
                    data.uc = v1.TextureCoordinate.x;
                    data.ud = v3.TextureCoordinate.x;
                    
                    data.va = v2.TextureCoordinate.y;
                    data.vb = v3.TextureCoordinate.y;
                    data.vc = v1.TextureCoordinate.y;
                    data.vd = v3.TextureCoordinate.y;
                    
                    self.processScanLine(data, va: v2, vb: v3, vc: v1, vd: v3, color: color, texture: texture);
                }
            }
        }
    }
    
    private func render(camera:SECamera, light:SELight, meshes:[SEMesh]) -> Void
    {
        let viewMatrix = SE3DMath.Matrix.LookAtLH(camera.position, target: camera.target, up: SE3DMath.Vector3.Up());
        let projectionMatrix = SE3DMath.Matrix.PerspectiveFovLH(0.78, aspect: Float(self.workingWidth) / Float(self.workingHeight), znear: 0.01, zfar: 1.0);
        
        let lightColor = light.color;
        let lightPos = light.position;
        
        for (var index = 0; index < meshes.count; index++) {
            let cMesh = meshes[index];
            
            let worldMatrix = SE3DMath.Matrix.RotationYawPitchRoll(cMesh.rotation.y, pitch: cMesh.rotation.x, roll: cMesh.rotation.z).multiply(SE3DMath.Matrix.Translation(cMesh.position.x, y: cMesh.position.y, z: cMesh.position.z));
            
            let worldView = worldMatrix.multiply(viewMatrix);
            let transformMatrix = worldView.multiply(projectionMatrix);
            
            for (var indexFaces = 0; indexFaces < cMesh.faces.count; indexFaces++) {
                let currentFace = cMesh.faces[indexFaces];
                
                let normaVW = currentFace.Normal.transformVector(worldView);//正交变换
                
                if (normaVW.z < 0) {
                    let vertexA = cMesh.vertices[currentFace.A];
                    let vertexB = cMesh.vertices[currentFace.B];
                    let vertexC = cMesh.vertices[currentFace.C];
                    
                    let pixelA = self.project(vertexA, transMatrix: transformMatrix, worldMatrix: worldMatrix);
                    let pixelB = self.project(vertexB, transMatrix: transformMatrix, worldMatrix: worldMatrix);
                    let pixelC = self.project(vertexC, transMatrix: transformMatrix, worldMatrix: worldMatrix);
                    
                    self.drawTriangle(pixelA, v2: pixelB, v3: pixelC, color: lightColor, lightPos: lightPos, texture: cMesh.texture);
                }
            }
        }
    }
    
    private func createMeshesFromJSON(jsonData:NSData) -> [SEMesh] {
        var meshes = [SEMesh]();
        var materials = [String:[String:String]]();
        
        let jsonDict = try! NSJSONSerialization.JSONObjectWithData(jsonData,options: NSJSONReadingOptions.MutableContainers) as! NSDictionary;
        
        let jsonMaterials = jsonDict["materials"] as! NSArray;
        let jsonMeshes = jsonDict["meshes"] as! NSArray;
        
        for (var materialIndex = 0; materialIndex < jsonMaterials.count; materialIndex++) {
            var material = [String:String]();
            let jsonMaterial = jsonMaterials[materialIndex] as! NSDictionary;
            material["Name"] = jsonMaterial["name"] as? String;
            let mid = jsonMaterial["id"] as? String;
            material["ID"] = mid;
            let diffuseTexture=jsonMaterial["diffuseTexture"] as! NSDictionary;
            material["DiffuseTextureName"] = diffuseTexture["name"] as? String;
            materials[mid!] = material;
        }
        
        for (var meshIndex = 0; meshIndex < jsonMeshes.count; meshIndex++) {
            let jsonMesh = jsonMeshes[meshIndex] as! NSDictionary;
            
            let verticesArray = jsonMesh["vertices"] as! NSArray;
            let indicesArray = jsonMesh["indices"] as! NSArray;
            let uvCount = Int(jsonMesh["uvCount"] as! NSNumber);
            
            var verticesStep = 1;
            
            switch (uvCount) {
            case 0:
                verticesStep = 6;
                break;
            case 1:
                verticesStep = 8;
                break;
            case 2:
                verticesStep = 10;
                break;
            default:
                break;
            }
            
            let verticesCount = verticesArray.count / verticesStep;
            let facesCount = indicesArray.count / 3;
            
            let mesh = SEMesh(name: jsonMesh["name"] as! String, verticesCount: verticesCount, facesCount: facesCount);
            
            for (var index = 0; index < verticesCount; index++) {
                let x = Float(verticesArray[index * verticesStep] as! NSNumber);
                let y = Float(verticesArray[index * verticesStep + 1] as! NSNumber);
                let z = Float(verticesArray[index * verticesStep + 2] as! NSNumber);
                
                let nx = Float(verticesArray[index * verticesStep + 3] as! NSNumber);
                let ny = Float(verticesArray[index * verticesStep + 4] as! NSNumber);
                let nz = Float(verticesArray[index * verticesStep + 5] as! NSNumber);
                
                let vertex = Vertex()
                vertex.Coordinate = SE3DMath.Vector3(x:x, y:y, z:z);
                vertex.Normal = SE3DMath.Vector3(x:nx, y:ny, z:nz);
                if (uvCount > 0) {
                    let u = Float(verticesArray[index * verticesStep + 6] as! NSNumber);
                    let v = Float(verticesArray[index * verticesStep + 7] as! NSNumber);
                    vertex.TextureCoordinate = SE3DMath.Vector2(x:u, y:v);
                } else {
                    vertex.TextureCoordinate = SE3DMath.Vector2(x:0, y:0);
                }
                mesh.vertices.append(vertex);
            }
            
            for (var index = 0; index < facesCount; index++) {
                let a = Int(indicesArray[index * 3] as! NSNumber);
                let b = Int(indicesArray[index * 3 + 1] as! NSNumber);
                let c = Int(indicesArray[index * 3 + 2] as! NSNumber);
                let face = Face()
                face.A = a;
                face.B = b;
                face.C = c;
                mesh.faces.append(face);
            }
            
            let position = jsonMesh["position"]!;
            mesh.position = SE3DMath.Vector3(x: Float(position[0] as! NSNumber), y: Float(position[1] as! NSNumber), z: Float(position[2] as! NSNumber));
            
            if (uvCount > 0) {
                let meshTextureID = jsonMesh["materialId"] as! String;
                let meshTextureName = (materials[meshTextureID])!["DiffuseTextureName"];
                mesh.texture = SETexture(fileName: meshTextureName!, width: 512, height: 512);
            }
            
            mesh.computeFacesNormal();
            
            meshes.append(mesh);
        }
        return meshes;
    }
    
    
}
