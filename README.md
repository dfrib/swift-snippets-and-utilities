# Swift Snippets and Utilities

This repository contains some Swift snippets and utilities. Experimental.

_Swift 2.1.1._

## Sources

**`EquatableConstruct.swift`**

> Generic conformance of class and structure types to `Equatable` protocol using runtime introspection for automatic property-by-property comparison. Limited to constructs containing only nominal types (e.g., no closures as construct properties).
>
> ```swift
> struct MyStruct { ... }
>
> /* Conform construct to EquatableConstruct */
> extension MyStruct : EquatableConstruct { }
>
> /* Construct will automatically conform to Equatable
>    with property-by-property comparison    */
> var foo = MyStruct(myInt: 1, myString: "foo")
> var bar = MyStruct(myInt: 1, myString: "bar")
>
> foo == bar             /* false */
> bar.myString = "foo"
> foo == bar             /* true  */
> ```

**`... .swift`**
