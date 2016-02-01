//
//  EquatableConstruct.swift
//
//  Created by David Friberg on 1/2/31.
//
//  Copyright (c) 2016 David Friberg.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//===----------------------------------------------------------------------===//
///
/// EquatableConstruct
///
/// Generic conformance of class and structure types to Equatable using runtime 
/// introspection for automatic property-by-property comparison.
///
/// Constructs conforming to EquatableConstruct are equatable.
///
/// Notes:
/// - Will be slower than a construct-custom conformance to Equatable,
///   probably negligible for non-heavy construct comparison usage.construct
/// - Naturally limited to constructs which contain only nominal types that; 
///   e.g. not intended for constructs containing closures (the latter can
///   never conform to PseudoEquatableType).
///
protocol EquatableConstruct : Equatable { }

/*  Heterogeneous protocol acts as generic type constraint
    for allowed property types in EquatableConstruct         */
protocol PseudoEquatableType {
    func isEqualTo(other: PseudoEquatableType) -> Bool
}

extension PseudoEquatableType where Self : Equatable {
    func isEqualTo(other: PseudoEquatableType) -> Bool {
        if let o = other as? Self { return self == o }
        return false
    }
}

/* Extend fundamental (equatable) Swift types to PseudoEquatableType  */
extension Bool : PseudoEquatableType {}

extension Int : PseudoEquatableType {}
extension Int8 : PseudoEquatableType {}
extension Int16 : PseudoEquatableType {}
extension Int32 : PseudoEquatableType {}
extension Int64 : PseudoEquatableType {}

extension UInt : PseudoEquatableType {}
extension UInt8 : PseudoEquatableType {}
extension UInt16 : PseudoEquatableType {}
extension UInt32 : PseudoEquatableType {}
extension UInt64 : PseudoEquatableType {}

extension Double : PseudoEquatableType {}
extension Float : PseudoEquatableType {}
extension Float80 : PseudoEquatableType {}

extension String : PseudoEquatableType {}
// ...

/*  EquatableConstruct conformance to Equatable  */
func ==<T: EquatableConstruct>(lhs: T, rhs: T) -> Bool {
    
    let mirrorLhs = Mirror(reflecting: lhs)
    let mirrorRhs = Mirror(reflecting: rhs)
    
    guard let displayStyle = mirrorLhs.displayStyle
        where (displayStyle == .Struct || displayStyle == .Class) else {
            
            print("Invalid use: type is not a construct.")
            return false
    }
    
    let childrenLhs = mirrorLhs.children.filter { $0.label != nil }
    let childrenRhs = mirrorRhs.children.filter { $0.label != nil }
    
    if childrenLhs.count == childrenRhs.count {
        
        for i in 0..<childrenLhs.count {
            
            guard let valLhs = childrenLhs[i].value as? PseudoEquatableType,
                valRhs = childrenRhs[i].value as? PseudoEquatableType else {
                    print("Invalid use: Properties 'lhs.\(childrenLhs[i].label!)'",
                        "and/or 'rhs.\(childrenRhs[i].label!)' are/is not of",
                        "PseudoEquatableType type.")
                    return false
            }
            
            if !valLhs.isEqualTo(valRhs) {
                return false
            }
        }
    }
        
    else {
        return false
    }
    
    return true
}

//===----------------------------------------------------------------------===//
// Example usage

struct MyStruct {
    var myInt: Int = 0
    var myString: String = ""
}

class MyClass {
    var myInt: Int
    var myString: String
    var myStruct: MyStruct
    
    init(myInt: Int, myString: String, myStruct: MyStruct) {
        self.myInt = myInt
        self.myString = myString
        self.myStruct = myStruct
    }
}

/* As a MyStruct instance is contained in MyClass, extend MyStruct to PseudoEquatableType
   to add the type to allowed property types in EquatableConstruct    */
extension MyStruct : PseudoEquatableType {}

/* Conformance to EquatableConstruct implies conformance to Equatable */
extension MyStruct : EquatableConstruct {}
extension MyClass : EquatableConstruct {}

/* Example */
var aa = MyStruct()
var bb = MyStruct()

aa == bb            // true
aa.myInt = 1
aa == bb            // false

var a = MyClass(myInt: 10, myString: "foo", myStruct: aa)
var b = MyClass(myInt: 10, myString: "foo", myStruct: aa)

a == b              // true
a.myInt = 2
a == b              // false
b.myInt = 2
b.myString = "Foo"
a.myString = "Foo"
a == b              // true
a.myStruct.myInt = 2
a == b              // false