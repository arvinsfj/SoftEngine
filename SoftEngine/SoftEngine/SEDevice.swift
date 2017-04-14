//
//  SEDevice.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation

class SEDevice {
    fileprivate var defaultMeshes = [SEMesh]();
    fileprivate var defaultCamera = SECamera(position: SE3DMath.Vector3(x:0,y:0,z:10),target: SE3DMath.Vector3(x:0,y:0,z:0));
    fileprivate var defaultLight = SELight(position: SE3DMath.Vector3(x:0,y:0,z:10),color:SE3DMath.Color4(r: 255, g: 255, b: 255, a: 255));
    
    let workingWidth:Float = 330;
    let workingHeight:Float = 330;
    var backBuffer = [UInt8](repeating: 0xff, count: 330*330*4);
    var depthBuffer = [Float](repeating: 10000000, count: 330*330);
    
    var viewMatrix:SE3DMath.Matrix = SE3DMath.Matrix.Zero();
    var projectionMatrix:SE3DMath.Matrix = SE3DMath.Matrix.Zero();
    
    var lightColor:SE3DMath.Color4 = SE3DMath.Color4(r: 255, g: 255, b: 255, a: 255);
    var lightPos:SE3DMath.Vector3 = SE3DMath.Vector3(x:0,y:0,z:10);
    
    
    init(){}
    
    init(modelFileName:String){
        let filePath:String=Bundle.main.bundlePath + "/\(modelFileName)";
        let jsonData=try! Data(contentsOf: URL(fileURLWithPath: filePath));
        self.defaultMeshes = self.createMeshesFromJSON(jsonData);
        
        viewMatrix = SE3DMath.Matrix.LookAtLH(defaultCamera.position, target: defaultCamera.target, up: SE3DMath.Vector3.Up());
        projectionMatrix = SE3DMath.Matrix.PerspectiveFovLH(0.78, aspect: workingWidth / workingHeight, znear: 0.01, zfar: 1.0);
        
        lightColor = defaultLight.color;
        lightPos = defaultLight.position;
    }
    
    fileprivate func createMeshesFromJSON(_ jsonData:Data) -> [SEMesh] {
        var meshes = [SEMesh]();
        var materials = [String:[String:String]]();
        
        let jsonDict = try! JSONSerialization.jsonObject(with: jsonData,options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary;
        
        let jsonMaterials = jsonDict["materials"] as! NSArray;
        let jsonMeshes = jsonDict["meshes"] as! NSArray;
        
        for materialIndex in 0 ..< jsonMaterials.count {
            var material = [String:String]();
            let jsonMaterial = jsonMaterials[materialIndex] as! NSDictionary;
            material["Name"] = jsonMaterial["name"] as? String;
            let mid = jsonMaterial["id"] as? String;
            material["ID"] = mid;
            let diffuseTexture=jsonMaterial["diffuseTexture"] as! NSDictionary;
            material["DiffuseTextureName"] = diffuseTexture["name"] as? String;
            materials[mid!] = material;
        }
        
        for meshIndex in 0 ..< jsonMeshes.count {
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
            
            for index in 0 ..< verticesCount {
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
            
            for index in 0 ..< facesCount {
                let a = Int(indicesArray[index * 3] as! NSNumber);
                let b = Int(indicesArray[index * 3 + 1] as! NSNumber);
                let c = Int(indicesArray[index * 3 + 2] as! NSNumber);
                let face = Face()
                face.A = a;
                face.B = b;
                face.C = c;
                mesh.faces.append(face);
            }
            
            let position = jsonMesh["position"] as! NSArray;
            mesh.position = SE3DMath.Vector3(x: position[0] as! Float, y: position[1] as! Float, z: position[2] as! Float);
            
            if (uvCount > 0) {
                let meshTextureID = jsonMesh["materialId"] as! String;
                let meshTextureName = (materials[meshTextureID])!["DiffuseTextureName"];
                mesh.texture = SETexture(fileName: meshTextureName!);
            }
            
            mesh.computeFacesNormal();
            
            meshes.append(mesh);
        }
        return meshes;
    }
    
    func clear() -> Void {//59 fps
        self.backBuffer = [UInt8](repeating: 0xff, count: 330*330*4);
        self.depthBuffer = [Float](repeating: 10000000, count: 330*330);
    }
    
    func update(updateMesh:([SEMesh])->Void) -> Void {//59 fps
        updateMesh(self.defaultMeshes);
        render();
    }
    
    func show(updateImage:@escaping ([UInt8])->Void) -> Void {//59 fps
        updateImage(self.backBuffer);
    }
    
    //渲染字符画，按照行列组件灰度字符串，换行使用"\n"
    let chars  = [" @"," #"," $"," ="," *"," !"," ;"," :"," ~"," -"," ,"," .","  ","  "];
    let len: Int = 330*330; var str: String = ""; var i: Int = 0;
    func showAscii(updateImage:@escaping (String)->Void) -> Void {//59 fps
        str = ""; i = 0;
        while i < len {
            str += chars[(Int)(self.backBuffer[i<<2]/20)]; i+=1;
            if i%330 == 0 { str += "\n"; }
        }
        updateImage(str);
    }
    
    fileprivate func render() -> Void {//30 fps
        render(self.defaultCamera, light: self.defaultLight, meshes: self.defaultMeshes)
    }
    
    fileprivate func computeNDotL(_ pointPos:SE3DMath.Vector3, normal:SE3DMath.Vector3, lightPos:SE3DMath.Vector3) -> Float
    {
        let lightDir = lightPos.sub(pointPos).normalize();
        //normal=normal.normalize();
        return max(0, normal.dot(lightDir));
    }
    
    fileprivate func clamp(_ value:Float, minValue:Float = 0 , maxValue:Float = 1) -> Float {
        return max(minValue, min(value, maxValue));
    }
    
    fileprivate func interpolate(_ minValue:Float = 0, maxValue:Float = 1, gradient:Float) -> Float {
        return minValue + (maxValue - minValue) * gradient;//self.clamp(gradient);
    }
    
    fileprivate func interpolate(_ minValue:Float = 0, lenght:Float = 1, gradient:Float) -> Float {
        return minValue + lenght * gradient;//self.clamp(gradient);
    }
    
    fileprivate func processScanLine(_ data:SEData, va:Vertex, vb:Vertex, vc:Vertex, vd:Vertex, color:SE3DMath.Color4, texture:SETexture?) -> Void
    {
        let pa = va.Coordinate;
        let pb = vb.Coordinate;
        let pc = vc.Coordinate;
        let pd = vd.Coordinate;
        
        let gradient1 = pa.y != pb.y ? (data.curY - pa.y) / (pb.y - pa.y) : 1;
        let gradient2 = pc.y != pd.y ? (data.curY - pc.y) / (pd.y - pc.y) : 1;
        
        let sx = interpolate(pa.x, maxValue: pb.x, gradient: gradient1);
        let ex = interpolate(pc.x, maxValue: pd.x, gradient: gradient2);
        let xlen = ex - sx;
        
        let z1 = interpolate(pa.z, maxValue: pb.z, gradient: gradient1);
        let z2 = interpolate(pc.z, maxValue: pd.z, gradient: gradient2);
        let zlen = z2 - z1;
        
        let snl = interpolate(data.ndotla, maxValue: data.ndotlb, gradient: gradient1);
        let enl = interpolate(data.ndotlc, maxValue: data.ndotld, gradient: gradient2);
        let nllen = enl - snl;
        
        let su = interpolate(data.ua, maxValue: data.ub, gradient: gradient1);
        let eu = interpolate(data.uc, maxValue: data.ud, gradient: gradient2);
        let ulen = eu - su;
        
        let sv = interpolate(data.va, maxValue: data.vb, gradient: gradient1);
        let ev = interpolate(data.vc, maxValue: data.vd, gradient: gradient2);
        let vlen = ev - sv;
        
        let color_r = (color.r);
        let color_g = (color.g);
        let color_b = (color.b);
        //let color_a = UInt8(color.a);
        
        //55 fps
        let xend = ex;
        let curY = data.curY;
        let cury = curY * workingWidth;
        
        var x: Float = sx;
        while x < xend
        {
            if (x >= 0 && curY >= 0 && x < workingWidth && data.curY < workingHeight)
            {
                let gradient = (x - sx) / xlen;
                let z = interpolate(z1, lenght: zlen, gradient: gradient);
                let index = Int(x) + Int(cury);
                if (z < depthBuffer[index]) {
                    depthBuffer[index] = z;
                    let ndotl = interpolate(snl, lenght: nllen, gradient: gradient);
                    let index4 = index << 2;
                    if let tex = texture {
                        let u = interpolate(su, lenght: ulen, gradient: gradient);
                        let v = interpolate(sv, lenght: vlen, gradient: gradient);
                        let texColor = tex.map(u, tv: v);
                        backBuffer[index4] = UInt8(color_r * ndotl * texColor.r);
                        backBuffer[index4+1] = UInt8(color_g * ndotl * texColor.g);
                        backBuffer[index4+2] = UInt8(color_b * ndotl * texColor.b);
                        backBuffer[index4+3] = 255;//color_a;
                    }else{
                        backBuffer[index4] = UInt8(color_r * ndotl);
                        backBuffer[index4+1] = UInt8(color_g * ndotl);
                        backBuffer[index4+2] = UInt8(color_b * ndotl);
                        backBuffer[index4+3] = 255;//color_a;
                    }
                }
            }
            x += 1;
        }
    }
    
    private func drawTriangle(_ v1:Vertex, v2:Vertex, v3:Vertex, lightColor:SE3DMath.Color4, lightPos:SE3DMath.Vector3, texture:SETexture?) -> Void
    {
        var v1 = v1, v2 = v2, v3 = v3
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
        //以上将v1放置在y轴最低点，v3放置在最高点，v2放置在中间
        
        let p1 = v1.Coordinate;
        let p2 = v2.Coordinate;
        let p3 = v3.Coordinate;
        
        let nl1 = self.computeNDotL(v1.WorldCoordinate, normal: v1.Normal, lightPos: lightPos);
        let nl2 = self.computeNDotL(v2.WorldCoordinate, normal: v2.Normal, lightPos: lightPos);
        let nl3 = self.computeNDotL(v3.WorldCoordinate, normal: v3.Normal, lightPos: lightPos);
        
        let data = SEData();
        
        let dP2P1:Float = p2.y > p1.y ? (p2.x - p1.x) / (p2.y - p1.y) : 0;
        let dP3P1:Float = p3.y > p1.y ? (p3.x - p1.x) / (p3.y - p1.y) : 0;
        
        if (dP2P1 > dP3P1) {
            var y = Int(p1.y);
            while y <= Int(p3.y) {
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
                    
                    self.processScanLine(data, va: v1, vb: v3, vc: v1, vd: v2, color: lightColor, texture: texture);
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
                    
                    self.processScanLine(data, va: v1, vb: v3, vc: v2, vd: v3, color: lightColor, texture: texture);
                }
                y += 1;
            }
        } else {
            var y = Int(p1.y);
            while y <= Int(p3.y) {
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
                    
                    self.processScanLine(data, va: v1, vb: v2, vc: v1, vd: v3, color: lightColor, texture: texture);
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
                    
                    self.processScanLine(data, va: v2, vb: v3, vc: v1, vd: v3, color: lightColor, texture: texture);
                }
                y += 1;
            }
        }
    }
    
    fileprivate func project(_ vertex:Vertex, transMatrix:SE3DMath.Matrix, worldMatrix:SE3DMath.Matrix) -> Vertex {
        let point2d = vertex.Coordinate.transformPoint(transMatrix);
        let point3DWorld = vertex.Coordinate.transformPoint(worldMatrix);
        let normal3DWorld = vertex.Normal.transformPoint(worldMatrix);
        let x = point2d.x * workingWidth + workingWidth / 2.0;
        let y = -point2d.y * workingHeight + workingHeight / 2.0;
        return Vertex(Coordinate: SE3DMath.Vector3(x: x, y: y, z: point2d.z), WorldCoordinate: point3DWorld, TextureCoordinate: vertex.TextureCoordinate, Normal: normal3DWorld);
    }
    
    fileprivate func render(_ camera:SECamera, light:SELight, meshes:[SEMesh]) -> Void
    {
        
        for cMesh in meshes {
            
            let worldMatrix = SE3DMath.Matrix.RotationYawPitchRoll(cMesh.rotation.y, pitch: cMesh.rotation.x, roll: cMesh.rotation.z).multiply(SE3DMath.Matrix.Translation(cMesh.position.x, y: cMesh.position.y, z: cMesh.position.z));
            let worldView = worldMatrix.multiply(viewMatrix);
            let transformMatrix = worldView.multiply(projectionMatrix);
            
            for currentFace in cMesh.faces {
                
                let normaVW = currentFace.Normal.transformVector(worldView);//正交变换
                
                if (normaVW.z <= 0) {
                    let vertexA = cMesh.vertices[currentFace.A];
                    let vertexB = cMesh.vertices[currentFace.B];
                    let vertexC = cMesh.vertices[currentFace.C];
                    
                    let pixelA = project(vertexA, transMatrix: transformMatrix, worldMatrix: worldMatrix);
                    let pixelB = project(vertexB, transMatrix: transformMatrix, worldMatrix: worldMatrix);
                    let pixelC = project(vertexC, transMatrix: transformMatrix, worldMatrix: worldMatrix);
                    
                    self.drawTriangle(pixelA, v2: pixelB, v3: pixelC, lightColor: self.lightColor, lightPos: self.lightPos, texture: cMesh.texture);
                }
            }
        }
    }
}
