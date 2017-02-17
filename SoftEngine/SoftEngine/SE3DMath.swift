//
//  SE3DMath.swift
//  SoftEngine
//
//  Created by cz on 12/16/15.
//  Copyright © 2015 cz. All rights reserved.
//

import Foundation

class SE3DMath {
    
    class Color4 {
        var r:Float,g:Float,b:Float,a:Float
        
        init(r :Float,g :Float,b :Float,a :Float){
            self.r=r;
            self.g=g;
            self.b=b;
            self.a=a;
        }
        
        class func Default() -> Color4{
            return Color4(r:1,g:1,b:1,a:1);
        }
        
        func toString() -> String {
            return "{ R:\(self.r) G:\(self.g) B:\(self.b) A:\(self.a) }";
        }
    }
    
    class Vector2 {
        //
        var x:Float,y:Float
        
        init(x:Float, y:Float){
            self.x=x;
            self.y=y;
        }
        
        class func Zero() -> Vector2{
            return Vector2(x:0,y:0);
        }
        
        func toString() -> String {
            return "{ X:\(self.x) Y:\(self.y) }";
        }
        
        func add(_ otherV2:Vector2) -> Vector2{
            return Vector2(x: self.x+otherV2.x, y: self.y+otherV2.y);
        }
        
        func sub(_ otherV2:Vector2) -> Vector2{
            return Vector2(x: self.x-otherV2.x, y: self.y-otherV2.y);
        }
        
        func dot(_ otherV2:Vector2) -> Float{
            return (self.x * otherV2.x + self.y * otherV2.y);
        }
        
        func negate() -> Vector2{
            return Vector2(x: -self.x, y: -self.y);
        }
        
        func scale(_ scale:Float) -> Vector2{
            return Vector2(x: self.x * scale, y: self.y * scale);
        }
        
        func equal(_ otherV2:Vector2) -> Bool{
            return (self.x == otherV2.x && self.y == otherV2.y);
        }
        
        func lenSqu() -> Float{
            return (self.x * self.x + self.y * self.y);
        }
        
        func len() -> Float{
            return sqrt(self.x * self.x + self.y * self.y);
        }
        
        func normalize() -> Vector2{
            let len = self.len();
            if (len == 0) {
                return Vector2(x:0,y:0);
            }
            let num = 1.0 / len;
            return Vector2(x: self.x * num, y: self.y * num);
        }
        
        func copy() -> Vector2{
            return Vector2(x:self.x,y:self.y);
        }
        
        func distanceSqu(_ otherV2:Vector2) -> Float{
            let x = self.x - otherV2.x;
            let y = self.y - otherV2.y;
            return ((x * x) + (y * y));
        }
        
        func distance(_ otherV2:Vector2) -> Float{
            let x = self.x - otherV2.x;
            let y = self.y - otherV2.y;
            return sqrt((x * x) + (y * y));
        }
        
        func transform() -> Vector2{
            return Vector2(x:self.y, y:self.x);
        }
    }
    var vector2:Vector2 = Vector2.Zero();
    
    class Vector3 {
        //
        var x:Float,y:Float,z:Float
        
        init(x:Float, y:Float, z:Float){
            self.x=x;
            self.y=y;
            self.z=z;
        }
        
        class func Zero() -> Vector3{
            return Vector3(x:0,y:0,z:0);
        }
        
        class func FromArray(_ arr:[Float], offset:Int) -> Vector3 {
            
            return Vector3(x:arr[offset],y:arr[offset+1],z:arr[offset+2]);
            
        }
        
        class func Up() -> Vector3{
            return Vector3(x:0,y:1,z:0);
        }
        
        func toString() -> String {
            return "{ X:\(self.x) Y:\(self.y) Z:\(self.z) }";
        }
        
        //
        
        func add(_ otherV3:Vector3) -> Vector3{
            return Vector3(x: self.x+otherV3.x, y: self.y+otherV3.y, z: self.z+otherV3.z);
        }
        
        func sub(_ otherV3:Vector3) -> Vector3{
            return Vector3(x: self.x-otherV3.x, y: self.y-otherV3.y, z: self.z-otherV3.z);
        }
        
        func dot(_ otherV3:Vector3) -> Float{
            return (self.x * otherV3.x + self.y * otherV3.y + self.z * otherV3.z);
        }
        
        func cross(_ otherV3:Vector3) -> Vector3{
            let x = self.y * otherV3.z - self.z * otherV3.y;
            let y = self.z * otherV3.x - self.x * otherV3.z;
            let z = self.x * otherV3.y - self.y * otherV3.x;
            return Vector3(x: x, y: y, z: z);
        }
        
        func negate() -> Vector3{
            return Vector3(x: -self.x, y: -self.y, z: -self.z);
        }
        
        func scale(_ scale:Float) -> Vector3{
            return Vector3(x: self.x * scale, y: self.y * scale, z: self.z * scale);
        }
        
        func equal(_ otherV3:Vector3) -> Bool{
            return (self.x == otherV3.x && self.y == otherV3.y && self.z == otherV3.z);
        }
        
        func lenSqu() -> Float{
            return (self.x * self.x + self.y * self.y + self.z * self.z);
        }
        
        func len() -> Float{
            return sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
        }
        
        func normalize() -> Vector3{
            let len = self.len();
            if (len == 0) {
                return Vector3(x:0,y:0,z:0);
            }
            let num = 1.0 / len;
            return Vector3(x: self.x * num, y: self.y * num, z: self.z * num);
        }
        
        func copy() -> Vector3{
            return Vector3(x:self.x,y:self.y,z:self.z);
        }
        
        func transformPoint(_ transMatrix:Matrix) -> Vector3{
            let x = (self.x * transMatrix.m[0]) + (self.y * transMatrix.m[4]) + (self.z * transMatrix.m[8]) + transMatrix.m[12];
            let y = (self.x * transMatrix.m[1]) + (self.y * transMatrix.m[5]) + (self.z * transMatrix.m[9]) + transMatrix.m[13];
            let z = (self.x * transMatrix.m[2]) + (self.y * transMatrix.m[6]) + (self.z * transMatrix.m[10]) + transMatrix.m[14];
            let w = (self.x * transMatrix.m[3]) + (self.y * transMatrix.m[7]) + (self.z * transMatrix.m[11]) + transMatrix.m[15];
            return Vector3(x: x / w, y: y / w, z: z / w);
        }
        
        func transformVector(_ transMatrix:Matrix) -> Vector3{
            let x = (self.x * transMatrix.m[0]) + (self.y * transMatrix.m[4]) + (self.z * transMatrix.m[8]);
            let y = (self.x * transMatrix.m[1]) + (self.y * transMatrix.m[5]) + (self.z * transMatrix.m[9]);
            let z = (self.x * transMatrix.m[2]) + (self.y * transMatrix.m[6]) + (self.z * transMatrix.m[10]);
            return Vector3(x: x, y: y, z: z);
        }
        
        func distanceSqu(_ otherV3:Vector3) -> Float{
            let x = self.x - otherV3.x;
            let y = self.y - otherV3.y;
            let z = self.z - otherV3.z;
            return ((x * x) + (y * y) + (z * z));
        }
        
        func distance(_ otherV3:Vector3) -> Float{
            let x = self.x - otherV3.x;
            let y = self.y - otherV3.y;
            let z = self.z - otherV3.z;
            return sqrt((x * x) + (y * y) + (z * z));
        }
    }
    var vector3:Vector3 = Vector3.Zero();
    
    class Matrix {
        //
        var m=[Float]();
        
        init(arr:[Float]){
            self.m=arr;
        }
        
        class func Zero() -> Matrix {
            let zeroArr:[Float]=[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            return Matrix(arr: zeroArr);
        }
        
        class func Identity() -> Matrix {
            let zeroArr:[Float]=[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
            return Matrix(arr: zeroArr);
        }
        
        class func FromValues(_ initialM11:Float, initialM12:Float, initialM13:Float, initialM14:Float, initialM21:Float, initialM22:Float, initialM23:Float, initialM24:Float, initialM31:Float, initialM32:Float, initialM33:Float, initialM34:Float, initialM41:Float, initialM42:Float, initialM43:Float, initialM44:Float) -> Matrix {
            var mValues=[Float](repeating: 0.0, count: 16);
            mValues[0] = initialM11;
            mValues[1] = initialM12;
            mValues[2] = initialM13;
            mValues[3] = initialM14;
            mValues[4] = initialM21;
            mValues[5] = initialM22;
            mValues[6] = initialM23;
            mValues[7] = initialM24;
            mValues[8] = initialM31;
            mValues[9] = initialM32;
            mValues[10] = initialM33;
            mValues[11] = initialM34;
            mValues[12] = initialM41;
            mValues[13] = initialM42;
            mValues[14] = initialM43;
            mValues[15] = initialM44;
            return Matrix(arr: mValues);
        }
        
        class func RotationX(_ angle:Float) -> Matrix {
            let result = Matrix.Zero();
            let s = sin(angle);
            let c = cos(angle);
            result.m[0] = 1.0;
            result.m[15] = 1.0;
            result.m[5] = c;
            result.m[10] = c;
            result.m[9] = -s;
            result.m[6] = s;
            return result;
        }
        
        class func RotationY(_ angle:Float) -> Matrix {
            let result = Matrix.Zero();
            let s = sin(angle);
            let c = cos(angle);
            result.m[5] = 1.0;
            result.m[15] = 1.0;
            result.m[0] = c;
            result.m[2] = -s;
            result.m[8] = s;
            result.m[10] = c;
            return result;
        }
        
        class func RotationZ(_ angle:Float) -> Matrix {
            let result = Matrix.Zero();
            let s = sin(angle);
            let c = cos(angle);
            result.m[10] = 1.0;
            result.m[15] = 1.0;
            result.m[0] = c;
            result.m[1] = s;
            result.m[4] = -s;
            result.m[5] = c;
            return result;
        }
        
        class func RotationAxis(_ axis:Vector3, angle:Float) -> Matrix {
            let s = sin(-angle);
            let c = cos(-angle);
            let c1 = 1 - c;
            let _ = axis.normalize();
            let result = Matrix.Zero();
            result.m[0] = (axis.x * axis.x) * c1 + c;
            result.m[1] = (axis.x * axis.y) * c1 - (axis.z * s);
            result.m[2] = (axis.x * axis.z) * c1 + (axis.y * s);
            result.m[3] = 0.0;
            result.m[4] = (axis.y * axis.x) * c1 + (axis.z * s);
            result.m[5] = (axis.y * axis.y) * c1 + c;
            result.m[6] = (axis.y * axis.z) * c1 - (axis.x * s);
            result.m[7] = 0.0;
            result.m[8] = (axis.z * axis.x) * c1 - (axis.y * s);
            result.m[9] = (axis.z * axis.y) * c1 + (axis.x * s);
            result.m[10] = (axis.z * axis.z) * c1 + c;
            result.m[11] = 0.0;
            result.m[15] = 1.0;
            return result;
        }
        
        class func RotationYawPitchRoll(_ yaw:Float, pitch:Float, roll:Float) -> Matrix {
            return Matrix.RotationZ(roll).multiply(Matrix.RotationX(pitch)).multiply(Matrix.RotationY(yaw));
        };
        
        class func Scale(_ x:Float, y:Float, z:Float) -> Matrix {
            let result = Matrix.Zero();
            result.m[0] = x;
            result.m[5] = y;
            result.m[10] = z;
            result.m[15] = 1.0;
            return result;
        }
        
        class func ScaleAxis(_ axis:Vector3) -> Matrix {
            let result = Matrix.Zero();
            result.m[0] = axis.x;
            result.m[5] = axis.y;
            result.m[10] = axis.z;
            result.m[15] = 1.0;
            return result;
        }
        
        class func Translation(_ x:Float, y:Float, z:Float) -> Matrix {
            let result = Matrix.Identity();
            result.m[12] = x;
            result.m[13] = y;
            result.m[14] = z;
            return result;
        }
        
        
        class func LookAtLH(_ eye:Vector3, target:Vector3, up:Vector3) -> Matrix {
            var zAxis = target.sub(eye);
            zAxis=zAxis.normalize();
            var xAxis = up.cross(zAxis);
            xAxis=xAxis.normalize();
            var yAxis = zAxis.cross(xAxis);
            yAxis=yAxis.normalize();
            let ex = -xAxis.dot(eye);
            let ey = -yAxis.dot(eye);
            let ez = -zAxis.dot(eye);
            return Matrix.FromValues(xAxis.x, initialM12:yAxis.x, initialM13:zAxis.x, initialM14:0, initialM21:xAxis.y, initialM22:yAxis.y, initialM23:zAxis.y, initialM24:0, initialM31:xAxis.z,initialM32: yAxis.z, initialM33:zAxis.z, initialM34:0, initialM41:ex, initialM42:ey, initialM43:ez, initialM44:1);
        }
        
        class func PerspectiveLH(_ width:Float, height:Float, znear:Float, zfar:Float) -> Matrix {
            let matrix = Matrix.Zero();
            matrix.m[0] = (2.0 * znear) / width;
            matrix.m[1] = 0.0;
            matrix.m[2] = 0.0;
            matrix.m[3] = 0.0;
            matrix.m[5] = (2.0 * znear) / height;
            matrix.m[4] = 0.0;
            matrix.m[6] = 0.0;
            matrix.m[7] = 0.0;
            matrix.m[10] = -zfar / (znear - zfar);
            matrix.m[8] = 0.0;
            matrix.m[9] = 0.0;
            matrix.m[11] = 1.0;
            matrix.m[12] = 0.0;
            matrix.m[13] = 0.0;
            matrix.m[15] = 0.0;
            matrix.m[14] = (znear * zfar) / (znear - zfar);
            return matrix;
        }
        
        class func PerspectiveFovLH(_ fov:Float, aspect:Float, znear:Float, zfar:Float) -> Matrix {
            let matrix = Matrix.Zero();
            let ctan = 1.0 / (tan(fov * 0.5));
            matrix.m[0] = ctan / aspect;
            matrix.m[1] = 0.0;
            matrix.m[2] = 0.0;
            matrix.m[3] = 0.0;
            matrix.m[5] = ctan;
            matrix.m[4] = 0.0;
            matrix.m[6] = 0.0;
            matrix.m[7] = 0.0;
            matrix.m[8] = 0.0;
            matrix.m[9] = 0.0;
            matrix.m[10] = -zfar / (znear - zfar);
            matrix.m[11] = 1.0;
            matrix.m[12] = 0.0;
            matrix.m[13] = 0.0;
            matrix.m[15] = 0.0;
            matrix.m[14] = (znear * zfar) / (znear - zfar);
            return matrix;
        }
        
        class func Transpose(_ matrix:Matrix) -> Matrix {
            let result = Matrix.Zero();
            result.m[0] = matrix.m[0];
            result.m[1] = matrix.m[4];
            result.m[2] = matrix.m[8];
            result.m[3] = matrix.m[12];
            result.m[4] = matrix.m[1];
            result.m[5] = matrix.m[5];
            result.m[6] = matrix.m[9];
            result.m[7] = matrix.m[13];
            result.m[8] = matrix.m[2];
            result.m[9] = matrix.m[6];
            result.m[10] = matrix.m[10];
            result.m[11] = matrix.m[14];
            result.m[12] = matrix.m[3];
            result.m[13] = matrix.m[7];
            result.m[14] = matrix.m[11];
            result.m[15] = matrix.m[15];
            return result;
        }
        
        func copy() -> Matrix{
            var mCopy=[Float]();
            for i in 0 ..< self.m.count {
                mCopy[i]=self.m[i];
            }
            return Matrix(arr:mCopy);
        }
        
        func toString() -> String {
            return "{ m:\(self.m) }";
        }
        
        
        func isIdentity() -> Bool {
            if (self.m[0] != 1.0 || self.m[5] != 1.0 || self.m[10] != 1.0 || self.m[15] != 1.0) {
                return false;
            }
            if (self.m[12] != 0.0 || self.m[13] != 0.0 || self.m[14] != 0.0 || self.m[4] != 0.0 || self.m[6] != 0.0 || self.m[7] != 0.0 || self.m[8] != 0.0 || self.m[9] != 0.0 || self.m[11] != 0.0 || self.m[12] != 0.0 || self.m[13] != 0.0 || self.m[14] != 0.0) {
                return false;
            }
            return true;
        }
        
        func determinant() -> Float {
            let temp1 = (self.m[10] * self.m[15]) - (self.m[11] * self.m[14]);
            let temp2 = (self.m[9] * self.m[15]) - (self.m[11] * self.m[13]);
            let temp3 = (self.m[9] * self.m[14]) - (self.m[10] * self.m[13]);
            let temp4 = (self.m[8] * self.m[15]) - (self.m[11] * self.m[12]);
            let temp5 = (self.m[8] * self.m[14]) - (self.m[10] * self.m[12]);
            let temp6 = (self.m[8] * self.m[13]) - (self.m[9] * self.m[12]);
            return ((((self.m[0] * (((self.m[5] * temp1) - (self.m[6] * temp2)) + (self.m[7] * temp3))) - (self.m[1] * (((self.m[4] * temp1) - (self.m[6] * temp4)) + (self.m[7] * temp5)))) + (self.m[2] * (((self.m[4] * temp2) - (self.m[5] * temp4)) + (self.m[7] * temp6)))) - (self.m[3] * (((self.m[4] * temp3) - (self.m[5] * temp5)) + (self.m[6] * temp6))));
        }
        
        func toArray() -> [Float] {
            var mCopy=[Float]();
            for i in 0 ..< self.m.count {
                mCopy[i]=self.m[i];
            }
            return mCopy;
        }
        
        func invert() -> Matrix {
            let result = self.copy();
            let l1 = self.m[0];
            let l2 = self.m[1];
            let l3 = self.m[2];
            let l4 = self.m[3];
            let l5 = self.m[4];
            let l6 = self.m[5];
            let l7 = self.m[6];
            let l8 = self.m[7];
            let l9 = self.m[8];
            let l10 = self.m[9];
            let l11 = self.m[10];
            let l12 = self.m[11];
            let l13 = self.m[12];
            let l14 = self.m[13];
            let l15 = self.m[14];
            let l16 = self.m[15];
            let l17 = (l11 * l16) - (l12 * l15);
            let l18 = (l10 * l16) - (l12 * l14);
            let l19 = (l10 * l15) - (l11 * l14);
            let l20 = (l9 * l16) - (l12 * l13);
            let l21 = (l9 * l15) - (l11 * l13);
            let l22 = (l9 * l14) - (l10 * l13);
            let l23 = ((l6 * l17) - (l7 * l18)) + (l8 * l19);
            let l24 = -(((l5 * l17) - (l7 * l20)) + (l8 * l21));
            let l25 = ((l5 * l18) - (l6 * l20)) + (l8 * l22);
            let l26 = -(((l5 * l19) - (l6 * l21)) + (l7 * l22));
            let l27 = 1.0 / ((((l1 * l23) + (l2 * l24)) + (l3 * l25)) + (l4 * l26));
            let l28 = (l7 * l16) - (l8 * l15);
            let l29 = (l6 * l16) - (l8 * l14);
            let l30 = (l6 * l15) - (l7 * l14);
            let l31 = (l5 * l16) - (l8 * l13);
            let l32 = (l5 * l15) - (l7 * l13);
            let l33 = (l5 * l14) - (l6 * l13);
            let l34 = (l7 * l12) - (l8 * l11);
            let l35 = (l6 * l12) - (l8 * l10);
            let l36 = (l6 * l11) - (l7 * l10);
            let l37 = (l5 * l12) - (l8 * l9);
            let l38 = (l5 * l11) - (l7 * l9);
            let l39 = (l5 * l10) - (l6 * l9);
            result.m[0] = l23 * l27;
            result.m[4] = l24 * l27;
            result.m[8] = l25 * l27;
            result.m[12] = l26 * l27;
            result.m[1] = -(((l2 * l17) - (l3 * l18)) + (l4 * l19)) * l27;
            result.m[5] = (((l1 * l17) - (l3 * l20)) + (l4 * l21)) * l27;
            result.m[9] = -(((l1 * l18) - (l2 * l20)) + (l4 * l22)) * l27;
            result.m[13] = (((l1 * l19) - (l2 * l21)) + (l3 * l22)) * l27;
            result.m[2] = (((l2 * l28) - (l3 * l29)) + (l4 * l30)) * l27;
            result.m[6] = -(((l1 * l28) - (l3 * l31)) + (l4 * l32)) * l27;
            result.m[10] = (((l1 * l29) - (l2 * l31)) + (l4 * l33)) * l27;
            result.m[14] = -(((l1 * l30) - (l2 * l32)) + (l3 * l33)) * l27;
            result.m[3] = -(((l2 * l34) - (l3 * l35)) + (l4 * l36)) * l27;
            result.m[7] = (((l1 * l34) - (l3 * l37)) + (l4 * l38)) * l27;
            result.m[11] = -(((l1 * l35) - (l2 * l37)) + (l4 * l39)) * l27;
            result.m[15] = (((l1 * l36) - (l2 * l38)) + (l3 * l39)) * l27;
            return result;
        }
        
        func multiply(_ other:Matrix) -> Matrix {
            let result = Matrix.Zero();
            result.m[0] = self.m[0] * other.m[0] + self.m[1] * other.m[4] + self.m[2] * other.m[8] + self.m[3] * other.m[12];
            result.m[1] = self.m[0] * other.m[1] + self.m[1] * other.m[5] + self.m[2] * other.m[9] + self.m[3] * other.m[13];
            result.m[2] = self.m[0] * other.m[2] + self.m[1] * other.m[6] + self.m[2] * other.m[10] + self.m[3] * other.m[14];
            result.m[3] = self.m[0] * other.m[3] + self.m[1] * other.m[7] + self.m[2] * other.m[11] + self.m[3] * other.m[15];
            result.m[4] = self.m[4] * other.m[0] + self.m[5] * other.m[4] + self.m[6] * other.m[8] + self.m[7] * other.m[12];
            result.m[5] = self.m[4] * other.m[1] + self.m[5] * other.m[5] + self.m[6] * other.m[9] + self.m[7] * other.m[13];
            result.m[6] = self.m[4] * other.m[2] + self.m[5] * other.m[6] + self.m[6] * other.m[10] + self.m[7] * other.m[14];
            result.m[7] = self.m[4] * other.m[3] + self.m[5] * other.m[7] + self.m[6] * other.m[11] + self.m[7] * other.m[15];
            result.m[8] = self.m[8] * other.m[0] + self.m[9] * other.m[4] + self.m[10] * other.m[8] + self.m[11] * other.m[12];
            result.m[9] = self.m[8] * other.m[1] + self.m[9] * other.m[5] + self.m[10] * other.m[9] + self.m[11] * other.m[13];
            result.m[10] = self.m[8] * other.m[2] + self.m[9] * other.m[6] + self.m[10] * other.m[10] + self.m[11] * other.m[14];
            result.m[11] = self.m[8] * other.m[3] + self.m[9] * other.m[7] + self.m[10] * other.m[11] + self.m[11] * other.m[15];
            result.m[12] = self.m[12] * other.m[0] + self.m[13] * other.m[4] + self.m[14] * other.m[8] + self.m[15] * other.m[12];
            result.m[13] = self.m[12] * other.m[1] + self.m[13] * other.m[5] + self.m[14] * other.m[9] + self.m[15] * other.m[13];
            result.m[14] = self.m[12] * other.m[2] + self.m[13] * other.m[6] + self.m[14] * other.m[10] + self.m[15] * other.m[14];
            result.m[15] = self.m[12] * other.m[3] + self.m[13] * other.m[7] + self.m[14] * other.m[11] + self.m[15] * other.m[15];
            return result;
        }
        
        func equal(_ other:Matrix) -> Bool {
            return (self.m[0] == other.m[0] && self.m[1] == other.m[1] && self.m[2] == other.m[2] && self.m[3] == other.m[3] && self.m[4] == other.m[4] && self.m[5] == other.m[5] && self.m[6] == other.m[6] && self.m[7] == other.m[7] && self.m[8] == other.m[8] && self.m[9] == other.m[9] && self.m[10] == other.m[10] && self.m[11] == other.m[11] && self.m[12] == other.m[12] && self.m[13] == other.m[13] && self.m[14] == other.m[14] && self.m[15] == other.m[15]);
        }
    }
    var matrix:Matrix = Matrix.Zero();
    
}
