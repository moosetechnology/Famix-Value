# Famix-Value

Famix-Value is a metamodel for representing runtime values and their corresponding types and entities in a [Famix](https://github.com/moosetechnology/Famix) model.  
The goal is to simplify working with values from languages other than Smalltalk by reifying them and linking them to the Famix model of the application that produced them.  
This project allows the values to be exported into code so that they can be recreated in their original programming language.

Note that this is a work in progress: there are plans to improve the readability of the code, for example by giving variables better names.

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

  void setFoo(int foo) { this.foo = foo; }
  void setBar(List<String> bar) { this.bar = bar; }
}
```

And the JSON serialization of an instance, produced by the [Jackson](https://github.com/FasterXML/jackson) library:
```json
{
  "@type": "MyClass",
  "foo": 42,
  "bar": ["java.util.ArrayList", ["Hello", "World"]]
}
```

Exporting this value produces the following code:
```java
MyClass myClass0 = new MyClass();
myClass.setFoo(42);
List<String> bar1 = new ArrayList<>();
bar1.add("Hello");
bar1.add("World");
myClass0.setBar(bar1);
```
