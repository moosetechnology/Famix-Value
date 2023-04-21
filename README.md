# Famix-Value

Famix-Value is a metamodel for representing runtime values and their corresponding types and entities in a Famix model.
The goal is to simplify working with values from languages other than Smalltalk by reifying them and linking them to the Famix model of the application that produced them.
This project allows exporting the values to code so that the values can be recreated in their original programming language.

## Installation

```st
Metacello new
  githubUser: 'moosetechnology' project: 'Famix-Value' commitish: 'main' path: 'src';
  baseline: 'FamixValue';
  load
```

## Example
Given the following Java class:
```java
public class MyClass {
  int foo;
  List<String> bar;
}
```

And the JSON serialization of an instance, produced by the Jackson library:
```json
{
  "@type": "foo.MyClass",
  "foo": 42,
  "bar": ["java.util.ArrayList", ["Hello", "World"]]
}
```

Exporting this value produces the following code:
```java
MyClass myClass0 = new MyClass();
int foo1 = 42;
myClass.setFoo(int1);
List<String> bar2 = new ArrayList<String>();
String string3 = "Hello";
bar2.add(string3);
String string4 = "World";
bar2.add(string4);
```
This is a work in progress: there are plans to improve the readability of the code, for example by inlining primitives or giving variables better names.
