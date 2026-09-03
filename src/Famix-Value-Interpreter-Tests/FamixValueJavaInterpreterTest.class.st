Class {
	#name : 'FamixValueJavaInterpreterTest',
	#superclass : 'TestCase',
	#instVars : [
		'interpreter',
		'famixModel'
	],
	#category : 'Famix-Value-Interpreter-Tests',
	#package : 'Famix-Value-Interpreter-Tests'
}

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> compilationUnitFor: class [

	^ FASTJavaCompilationUnit new
		  addClassDeclaration: class;
		  yourself
]

{ #category : 'resources' }
FamixValueJavaInterpreterTest >> expandFamixModelFrom: aFASTEntity [

	FamixValueJavaInterpreterFamixBuilder
		expand: famixModel
		from: aFASTEntity
]

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> loadClass: class [

	^ interpreter classLoader addCompilationUnit:
		  (self compilationUnitFor: class)
]

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> loadClasses: classes [

	| source units |
	units := classes collect: [ :class | self compilationUnitFor: class ].

	source := FamixValueJavaFASTSource new.
	units do: [ :unit | source addCompilationUnit: unit ].

	interpreter classLoader addSource: source.

	units do: [ :unit |
		| needsLoading |
		needsLoading := unit classDeclarations anySatisfy: [ :class |
			                (interpreter classLoader isTypeLoadedNamed:
				                 (unit qualifiedNameOf: class)) not ].

		needsLoading ifTrue: [
			interpreter classLoader addCompilationUnit: unit ] ].

	interpreter classLoader link
]

{ #category : 'resources' }
FamixValueJavaInterpreterTest >> minimalFamixModel [

	| model |
	model := FamixJavaModel new.

	#( 'boolean' 'byte' 'short' 'int' 'long' 'char' 'float' 'double' )
		do: [ :name | model newPrimitiveType name: name ].

	^ model
]

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> parseClass: aString [

	| class |
	class := self parseRootEntity: aString.

	self expandFamixModelFrom: class.
	self loadClass: class.
	interpreter classLoader link.

	^ class
]

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> parseCompilationUnit: source [

	^ ((JavaSmaCCProgramNodeImporterVisitor new parseCodeString: source)
		   allWithType: FASTJavaCompilationUnit) first
]

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> parseMethod: source [

	| class method |
	class := self parseRootEntity: 'class __TestClass__ {' , source , '}'.

	self expandFamixModelFrom: class.
	self loadClass: class.
	interpreter classLoader link.

	method := class declarations detect: [ :declaration |
		          declaration isMethodEntity ].

	^ method
]

{ #category : 'parsing' }
FamixValueJavaInterpreterTest >> parseRootEntity: aString [

	^ (JavaSmaCCProgramNodeImporterVisitor parseCodeMethodString: aString)
		  rootEntities anyOne
]

{ #category : 'running' }
FamixValueJavaInterpreterTest >> setUp [

	super setUp.
	famixModel := self minimalFamixModel.
	interpreter := FamixValueJavaInterpreter on: famixModel
]

{ #category : 'accessing' }
FamixValueJavaInterpreterTest >> sourceDirectory [

	^ FileLocator temp / 'FamixValueInterpreter' / self selector asString
]

{ #category : 'running' }
FamixValueJavaInterpreterTest >> tearDown [

	| directory |
	directory := self sourceDirectory.
	directory exists ifTrue: [ directory ensureDeleteAll ].

	super tearDown
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAllocationDoesNotIncludeStaticFields [

	| class object fieldNames |
	class := self parseClass: '
class Test {
	int x;
	static int shared;
}'.

	object := interpreter allocateObjectOf:
		          (interpreter classLoader
			           typeNamed: 'Test'
			           ifAbsent: [ self fail ]).

	fieldNames := object value collect: [ :attribute |
		              attribute runtimeField name ].

	self assertCollection: fieldNames hasSameElements: #( 'x' )
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAllocationIncludesInheritedInstanceFields [

	| unit type object fieldNames |
	unit := self parseCompilationUnit: '
class A {
	int x;
}

class B extends A {
	long y;
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	type := interpreter classLoader
		        typeNamed: 'B'
		        ifAbsent: [ self fail ].

	object := interpreter allocateObjectOf: type.

	fieldNames := object value collect: [ :attribute |
		              attribute runtimeField name ].

	self assert: fieldNames asSet equals: #( 'x' 'y' ) asSet
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAmbiguousOnDemandImportsFail [

	| unit source |
	self writeJavaSource: 'package first; class B {}' at: 'first/B.java'.

	self
		writeJavaSource: 'package second; class B {}'
		at: 'second/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unit := self parseCompilationUnit: '
package client;

import first.*;
import second.*;

class A {
	B value;
}'.

	self
		should: [ interpreter classLoader addCompilationUnit: unit ]
		raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAndShortCircuits [

	| method result |
	method := self parseMethod: 'static int test() {
		int x = 0;
		if (false && ++x > 0) {
			return -1;
		}
		return x;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 0
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testArgumentIsConvertedToParameterType [

	| class method result |
	class := self parseClass: 'class Test {
		long identity(long value) {
			return value;
		}

		static long test() {
			Test object = new Test();
			return object.identity(42);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testArrayAssignmentWidensIntToLong [

	| method result |
	method := self parseMethod: 'static long test() {
		long[] values = new long[1];
		values[0] = 2;
		return values[0];
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testArrayElementsAreIndependentLocations [

	| method result |
	method := self parseMethod: 'static int test() {
		int[] values = new int[2];
		values[0] = 3;
		values[1] = 4;
		return values[0] * 10 + values[1];
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 34
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAssignmentChangesVariable [

	| method result |
	method := self parseMethod: 'static int test() {
		int a = 1;
		a = 42;
		return a;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAssignmentInitializesOnlyTarget [

	| method result |
	method := self parseMethod: 'static int test() {
		int x;
		int y = 3;
		x = 4;
		return x * 10 + y;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 43
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testAssignmentWidensIntToLong [

	| method result |
	method := self parseMethod: 'static long test() {
		long x;
		x = 2;
		return x;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testBooleanOperationHasBooleanType [

	| method result |
	method := self parseMethod: 'static boolean test() {
		return true && !false;
	}'.

	result := interpreter execute: method.

	self assert: result value.
	self assert: result type name equals: 'boolean'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassHierarchyIsIndexed [

	| unit a b i j classLoader |
	unit := self parseCompilationUnit: '
class A {}

interface I {}

interface J {}

class B extends A implements I, J {}'.

	self expandFamixModelFrom: unit.

	classLoader := interpreter classLoader.
	classLoader addCompilationUnit: unit.

	a := classLoader
		     resolveTypeNamed: 'A'
		     in: (classLoader typeNamed: 'A' ifAbsent: [ self fail ])
				     declaringCompilationUnit.

	b := classLoader
		     resolveTypeNamed: 'B'
		     in: (classLoader typeNamed: 'B' ifAbsent: [ self fail ])
				     declaringCompilationUnit.

	i := classLoader
		     resolveTypeNamed: 'I'
		     in: (classLoader typeNamed: 'I' ifAbsent: [ self fail ])
				     declaringCompilationUnit.

	j := classLoader
		     resolveTypeNamed: 'J'
		     in: (classLoader typeNamed: 'J' ifAbsent: [ self fail ])
				     declaringCompilationUnit.

	self assert: b superclass identicalTo: a.
	self assert: (b interfaces includes: i).
	self assert: (b interfaces includes: j).

	self assert: (b isSubtypeOf: a).
	self assert: (b isSubtypeOf: i).
	self assert: (b isSubtypeOf: j).

	self deny: (a isSubtypeOf: b).
	self deny: (i isSubtypeOf: b)
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassInAnotherObservableCompilationUnitCanBeResolved [

	| classA classB source units unitInfo type |
	classA := self parseRootEntity: 'class A { B b; }'.
	classB := self parseRootEntity: 'class B {}'.

	units := {
		         (self compilationUnitFor: classA).
		         (self compilationUnitFor: classB) }.

	source := FamixValueJavaFASTSource new.
	units do: [ :unit | source addCompilationUnit: unit ].
	interpreter classLoader addSource: source.

	unitInfo := interpreter classLoader addCompilationUnit: units first.

	type := interpreter classLoader resolveTypeNamed: 'B' in: unitInfo.

	self assert: type qualifiedName equals: 'B'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassInheritsDefaultInterfaceMethod [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	default int value() {
		return 42;
	}
}

class A implements I {}

class Test {
	static int test() {
		A value = new A();
		return value.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassInitializationDoesNotInitializeOrdinarySuperinterface [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	int VALUE = Test.increment();
}

class A implements I {
	static int value = 42;
}

class Test {
	static int count = 0;

	static int increment() {
		count = count + 1;
		return count;
	}

	static int test() {
		int ignored = A.value;
		return count;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 0
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassInitializationInitializesDefaultMethodSuperinterface [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	int VALUE = Test.increment();

	default int value() {
		return VALUE;
	}
}

class A implements I {
	static int value = 42;
}

class Test {
	static int count = 0;

	static int increment() {
		count = count + 1;
		return count;
	}

	static int test() {
		int ignored = A.value;
		return count;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassModifiersAreIndexed [

	| unit typeInfo |
	unit := self parseCompilationUnit: '
public final class A {}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	typeInfo := interpreter classLoader
		            typeNamed: 'A'
		            ifAbsent: [ self fail ].

	self assert: typeInfo isPublic.
	self assert: typeInfo isFinal.
	self deny: typeInfo isAbstract
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testClassesCanBeLinkedAfterBothAreLoaded [

	| classA classB method invocation linkedMethod |
	classA := self parseRootEntity: 'class A {
		int test(B b) {
			return b.value();
		}
	}'.

	classB := self parseRootEntity: 'class B {
		int value() {
			return 42;
		}
	}'.

	self loadClasses: {
			classA.
			classB }.

	method := classA declarations detect: [ :each | each isMethodEntity ].

	invocation := method allChildren detect: [ :each | each isInvocation ].

	linkedMethod := interpreter classLoader methodForInvocation:
		                invocation.

	self assert: linkedMethod name equals: 'value'.
	self assert: linkedMethod declaringType name equals: 'B'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testComparisonCanControlIf [

	| method result |
	method := self parseMethod: 'static int test() {
		int x = 4;
		if (x * 2 == 8) {
			return 42;
		}
		return 0;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testComparisonHasBooleanType [

	| method result |
	method := self parseMethod: 'static boolean test() {
		return 1 < 2;
	}'.

	result := interpreter execute: method.

	self assert: result value.
	self assert: result type name equals: 'boolean'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testCompilationUnitWithoutPackageHasEmptyPackageName [

	| unit |
	unit := self parseCompilationUnit: 'class Test {}'.

	self assert: unit packageName equals: ''
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testConstructorInitializesObject [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Point {
	int x = 1;

	Point(int value) {
		x = value;
	}
}

class Test {
	static int test() {
		Point p = new Point(42);
		return p.x;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testDoubleArithmeticProducesDouble [

	| method result |
	method := self parseMethod: 'static double test() {
		return 1 + 2.5;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 3.5.
	self assert: result type name equals: 'double'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testExecutesClassLoadedFromSourceDirectory [

	| source unitA classA method result |
	self
		writeJavaSource: '
package example;

class B {
	int value() {
		return 42;
	}
}'
		at: 'example/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unitA := self parseCompilationUnit: '
package example;

class A {
	static int test() {
		B b = new B();
		return b.value();
	}
}'.

	self expandFamixModelFrom: unitA.
	interpreter classLoader addCompilationUnit: unitA.
	interpreter classLoader link.

	classA := unitA classDeclarations detect: [ :class |
		          class name = 'A' ].

	method := classA declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testExplicitConstructorInvocationEvaluatesArgumentsInCurrentFrame [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value;

	A(int value) {
		this.value = value;
	}
}

class B extends A {
	B(int value) {
		super(value + 1);
	}
}

class Test {
	static int test() {
		B b = new B(41);
		return b.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testExplicitConstructorRunsInstanceFieldInitializerOnce [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value = 20;

	A() {
		value = value + 2;
	}
}

class Test {
	static int test() {
		A a = new A();
		return a.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 22
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testExplicitSuperclassConstructorInvocation [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value;

	A(int value) {
		this.value = value;
	}
}

class B extends A {
	B() {
		super(42);
	}
}

class Test {
	static int test() {
		B b = new B();
		return b.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testFieldAssignmentWidensIntToLong [

	| class method result |
	class := self parseClass: 'class Test {
		long x;

		long get() {
			return this.x;
		}

		static long test() {
			Test object = new Test();
			object.x = 2;
			return object.x;
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testFirstSourceDirectoryWins [

	| firstRoot secondRoot firstSource secondSource classInfo |
	firstRoot := self sourceDirectory / 'first'.
	secondRoot := self sourceDirectory / 'second'.

	self
		writeJavaSource: '
package example;

class B {
	int value() {
		return 1;
	}
}'
		at: 'first/example/B.java'.

	self
		writeJavaSource: '
package example;

class B {
	int value() {
		return 2;
	}
}'
		at: 'second/example/B.java'.

	firstSource := FamixValueJavaSourceDirectory on: firstRoot.
	secondSource := FamixValueJavaSourceDirectory on: secondRoot.

	interpreter classLoader
		addSource: firstSource;
		addSource: secondSource.

	classInfo := interpreter classLoader loadTypeNamed: 'example.B'.

	self assert: classInfo loaded.
	self assert:
		(classInfo fastClass sourceCode includesSubstring: 'return 1')
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testFloatLiteralIsFloat [

	| method result |
	method := self parseMethod: 'float test() {
		return 2.5f;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.5.
	self assert: result type name equals: 'float'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testImplicitDefaultConstructorRunsInstanceFieldInitializer [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value = 42;
}

class Test {
	static int test() {
		A a = new A();
		return a.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'accessing' }
FamixValueJavaInterpreterTest >> testImplicitFieldAssignment [

	| class object setter getter result |
	class := self parseClass: 'class Test {
		long x;

		static Test create() {
			return new Test();
		}

		void set() {
			x = 42;
		}

		long get() {
			return x;
		}
	}'.

	object := interpreter execute:
		          (class declarations detect: [ :each |
			           each name = 'create' ]).

	setter := class declarations detect: [ :each | each name = 'set' ].

	getter := class declarations detect: [ :each | each name = 'get' ].

	interpreter execute: setter on: object with: #(  ).

	result := interpreter execute: getter on: object with: #(  ).

	self assert: result value equals: 42.
	self assert: result type name equals: 'long'
]

{ #category : 'accessing' }
FamixValueJavaInterpreterTest >> testImplicitFieldRead [

	| class method object result |
	class := self parseClass: 'class Test {
		int x;

		int get() {
			return x;
		}

		static Test create() {
			return new Test();
		}
	}'.

	object := interpreter execute:
		          (class declarations detect: [ :each |
			           each name = 'create' ]).

	method := class declarations detect: [ :each | each name = 'get' ].

	result := interpreter execute: method on: object with: #(  ).

	self assert: result value equals: 0
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testImplicitSuperInvocationRequiresZeroArgumentConstructor [

	| unit |
	unit := self parseCompilationUnit: '
class A {
	A(int value) {}
}

class B extends A {
	B() {}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	self should: [ interpreter classLoader link ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testImplicitSuperclassConstructorIsExecuted [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value;

	A() {
		value = 42;
	}
}

class B extends A {}

class Test {
	static int test() {
		B b = new B();
		return b.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInstanceFieldInitializerRunsBeforeConstructorBody [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Point {
	int x = 41;

	Point() {
		x = x + 1;
	}
}

class Test {
	static int test() {
		Point p = new Point();
		return p.x;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInstanceMethodInvocation [

	| class method result |
	class := self parseClass: 'class Counter {
		int count;

		int get() {
			return count;
		}

		static int test() {
			Counter counter = new Counter();
			counter.count = 42;
			return counter.get();
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInstanceMethodInvocationWithArguments [

	| class method result |
	class := self parseClass: 'class Calculator {
		int add(int a, int b) {
			return a + b;
		}

		static int test() {
			Calculator calculator = new Calculator();
			return calculator.add(20, 22);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testIntegerLiteralHasIntegerType [

	| method result |
	method := self parseMethod: 'static int test() {
		return 42;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42.
	self assert: result type name equals: 'int'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testIntegerLiteralIsInt [

	| method result |
	method := self parseMethod: 'int test() {
		return 2;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'int'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInterfaceAbstractMethodHasImplicitModifiers [

	| unit interface methodInfo |
	unit := self parseCompilationUnit: '
interface I {
	int value();
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	interface := interpreter classLoader
		             typeNamed: 'I'
		             ifAbsent: [ self fail ].

	methodInfo := interface methods detect: [ :method |
		              method name = 'value' ].

	self assert: methodInfo isPublic.
	self assert: methodInfo isAbstract.
	self deny: methodInfo isDefault.
	self deny: methodInfo isStatic.
	self deny: methodInfo isPrivate
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInterfaceDefaultMethodHasImplicitPublicModifier [

	| unit interface methodInfo |
	unit := self parseCompilationUnit: '
interface I {
	default int value() {
		return 42;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	interface := interpreter classLoader
		             typeNamed: 'I'
		             ifAbsent: [ self fail ].

	methodInfo := interface methods detect: [ :method |
		              method name = 'value' ].

	self assert: methodInfo isPublic.
	self assert: methodInfo isDefault.
	self deny: methodInfo isAbstract.
	self deny: methodInfo isStatic.
	self deny: methodInfo isPrivate
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInterfaceFieldHasImplicitModifiers [

	| unit interface fieldInfo |
	unit := self parseCompilationUnit: '
interface I {
	int VALUE = 42;
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	interface := interpreter classLoader
		             typeNamed: 'I'
		             ifAbsent: [ self fail ].

	fieldInfo := interface fieldNamed: 'VALUE'.

	self assert: fieldInfo isPublic.
	self assert: fieldInfo isStatic.
	self assert: fieldInfo isFinal.
	self deny: fieldInfo isPrivate.
	self deny: fieldInfo isProtected.
	self deny: fieldInfo isPackagePrivate
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInterfaceIsImplicitlyAbstract [

	| unit typeInfo |
	unit := self parseCompilationUnit: '
interface I {}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	typeInfo := interpreter classLoader
		            typeNamed: 'I'
		            ifAbsent: [ self fail ].

	self assert: typeInfo isAbstract
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInterfaceStaticMethodHasImplicitPublicModifier [

	| unit interface methodInfo |
	unit := self parseCompilationUnit: '
interface I {
	static int value() {
		return 42;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	interface := interpreter classLoader
		             typeNamed: 'I'
		             ifAbsent: [ self fail ].

	methodInfo := interface methods detect: [ :method |
		              method name = 'value' ].

	self assert: methodInfo isPublic.
	self assert: methodInfo isStatic.
	self deny: methodInfo isAbstract.
	self deny: methodInfo isDefault
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInvocationLoadsClassFromSourceDirectory [

	| source unitA classA method invocation linkedMethod |
	self
		writeJavaSource: '
package example;

class B {
	int value() {
		return 42;
	}
}'
		at: 'example/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unitA := self parseCompilationUnit: '
package example;

class A {
	int test(B b) {
		return b.value();
	}
}'.

	self expandFamixModelFrom: unitA.
	interpreter classLoader addCompilationUnit: unitA.
	interpreter classLoader link.

	self assert: (interpreter classLoader
			 typeNamed: 'example.B'
			 ifAbsent: [ self fail ]) loaded.

	classA := unitA classDeclarations detect: [ :class |
		          class name = 'A' ].

	method := classA declarations detect: [ :each | each name = 'test' ].

	invocation := method allChildren detect: [ :each | each isInvocation ].

	linkedMethod := interpreter classLoader methodForInvocation:
		                invocation.

	self assert: linkedMethod name equals: 'value'.
	self
		assert: linkedMethod declaringType qualifiedName
		equals: 'example.B'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInvocationLoadsReceiverClassFromSource [

	| classA classB source method |
	classA := self parseRootEntity: 'class A {
		int test(B b) {
			return b.value();
		}
	}'.

	classB := self parseRootEntity: 'class B {
		int value() {
			return 42;
		}
	}'.

	source := FamixValueJavaFASTSource new.
	source addCompilationUnit: (self compilationUnitFor: classB).

	interpreter classLoader addSource: source.
	self loadClass: classA.
	interpreter classLoader link.

	self assert:
		(interpreter classLoader typeNamed: 'B' ifAbsent: [ self fail ])
			loaded.

	method := classA declarations detect: [ :each | "Execution needs a B argument, so linking alone is actually
	the cleaner assertion for this particular test."
		          each name = 'test' ]
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInvocationThroughInterfaceTypeDispatchesToImplementation [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	int value();
}

class A implements I {
	public int value() {
		return 42;
	}
}

class Test {
	static int test() {
		I value = new A();
		return value.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testInvocationThroughSubinterfaceFindsInheritedMethod [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	int value();
}

interface J extends I {
}

class A implements J {
	public int value() {
		return 42;
	}
}

class Test {
	static int test() {
		J value = new A();
		return value.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLoadingClassRegistersCanonicalClassInfo [

	| class classInfo |
	class := self parseRootEntity: 'class Test {}'.
	self loadClass: class.

	classInfo := interpreter classLoader
		             typeNamed: 'Test'
		             ifAbsent: [ self fail ].

	self
		assert:
		(interpreter classLoader typeNamed: 'Test' ifAbsent: [ self fail ])
		identicalTo: classInfo.

	self assert: classInfo name equals: 'Test'.
	self assert: classInfo qualifiedName equals: 'Test'.
	self assert: classInfo isClass
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLocalCanBeAssignedAfterDeclaration [

	| method result |
	method := self parseMethod: 'static int test() {
		int x;
		x = 42;
		return x;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42.
	self assert: result type name equals: 'int'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLocalInitializationWidensIntToDouble [

	| method result |
	method := self parseMethod: 'static double test() {
		double x = 2;
		return x;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'double'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLocalInitializationWidensIntToLong [

	| method result |
	method := self parseMethod: 'static long test() {
		long x = 2;
		return x;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'accessing' }
FamixValueJavaInterpreterTest >> testLocalShadowsImplicitField [

	| class object method result |
	class := self parseClass: 'class Test {
		int x;

		static Test create() {
			return new Test();
		}

		int test() {
			int x = 42;
			return x;
		}
	}'.

	object := interpreter execute:
		          (class declarations detect: [ :each |
			           each name = 'create' ]).

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method on: object with: #(  ).

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLongArithmeticProducesLong [

	| method result |
	method := self parseMethod: 'static long test() {
		return 1 + 2L;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 3.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLongIncrementPreservesType [

	| method result |
	method := self parseMethod: 'static long test() {
		long x = 1L;
		x++;
		return x;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testLongLiteralIsLong [

	| method result |
	method := self parseMethod: 'long test() {
		return 2L;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodInvocationFindsInheritedMethod [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Parent {
	int value() {
		return 42;
	}
}

class Child extends Parent {
}

class Test {
	static int test() {
		Child child = new Child();
		return child.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodInvocationWidensReferenceToInterface [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
}

class Implementation implements I {
}

class Test {
	int value(I argument) {
		return 42;
	}

	static int test() {
		Test receiver = new Test();
		Implementation argument = new Implementation();
		return receiver.value(argument);
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodInvocationWidensReferenceToSuperclass [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Parent {
	int value(Parent argument) {
		return 42;
	}
}

class Child extends Parent {
}

class Test {
	static int test() {
		Parent receiver = new Parent();
		Child argument = new Child();
		return receiver.value(argument);
	}
}
'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionChoosesExactPrimitiveOverload [

	| class method result |
	class := self parseClass: 'class Test {
		int choose(int value) {
			return 1;
		}

		int choose(long value) {
			return 2;
		}

		static int test() {
			Test object = new Test();
			return object.choose(42);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionChoosesMostSpecificReferenceOverload [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Parent {}
class Child extends Parent {}

class Test {
	int choose(Parent value) {
		return 1;
	}

	int choose(Child value) {
		return 2;
	}

	static int test() {
		Test receiver = new Test();
		Child value = new Child();
		return receiver.choose(value);
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionChoosesNarrowestApplicablePrimitiveOverload [

	| class method result |
	class := self parseClass: 'class Test {
		int choose(long value) {
			return 1;
		}

		int choose(double value) {
			return 2;
		}

		static int test() {
			Test object = new Test();
			return object.choose(42);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionUsesApplicableOverload [

	| class method result |
	class := self parseClass: 'class Test {
		int choose(boolean value) {
			return 1;
		}

		long choose(long value) {
			return 2;
		}

		static long test() {
			Test object = new Test();
			return object.choose(42);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionUsesStaticTypeOfArithmeticExpression [

	| class method result |
	class := self parseClass: 'class Test {
		int choose(int value) {
			return 1;
		}

		int choose(long value) {
			return 2;
		}

		static int test() {
			Test object = new Test();
			return object.choose(20 + 22);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionUsesStaticTypeOfFieldAccess [

	| class method result |
	class := self parseClass: 'class Test {
		long x;

		int choose(int value) {
			return 1;
		}

		int choose(long value) {
			return 2;
		}

		static int test() {
			Test object = new Test();
			return object.choose(object.x);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionUsesStaticTypeOfNestedInvocation [

	| class method result |
	class := self parseClass: 'class Test {
		long produce() {
			return 42;
		}

		int consume(int value) {
			return 1;
		}

		int consume(long value) {
			return 2;
		}

		static int test() {
			Test object = new Test();
			return object.consume(object.produce());
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMethodResolutionUsesStaticTypeOfUnaryExpression [

	| class method result |
	class := self parseClass: 'class Test {
		int choose(int value) {
			return 1;
		}

		int choose(long value) {
			return 2;
		}

		static int test() {
			Test object = new Test();
			return object.choose(-42);
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMostSpecificDefaultInterfaceMethodDoesNotDependOnImplementsOrder [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	default int value() {
		return 1;
	}
}

interface J extends I {
	default int value() {
		return 2;
	}
}

class A implements J, I {}

class Test {
	static int test() {
		A value = new A();
		return value.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMultidimensionalArraysAreIndependent [

	| method result |
	method := self parseMethod: 'static long test() {
		long[][] values = new long[2][2];
		values[0][1] = 42;
		return values[0][1] + values[1][1];
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testMultidimensionalPrimitiveArray [

	| method result |
	method := self parseMethod: 'static long test() {
		long[][] values = new long[2][3];
		values[0][1] = 42;
		return values[0][1] + values[1][1];
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testNewObjectHasDefaultFieldValues [

	| class method result |
	class := self parseClass: 'class Counter {
		int x;

		static int test() {
			Counter counter = new Counter();
			return counter.x;
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 0.
	self assert: result type name equals: 'int'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testNotEquals [

	| method result |
	method := self parseMethod: 'static int test() {
		if (1 != 2) {
			return 42;
		}
		return 0;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testNullIsUnique [

	| method result |
	self skip. "TODO"
	method := self parseMethod: 'static boolean test() {
		Object a = null;
		Object b = null;
		return a == b;
	}'.

	result := interpreter execute: method.

	self assert: result value
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testNullLiteralReturnsUniqueNull [

	| literal result |
	literal := FASTJavaNullLiteral new.

	result := literal accept: interpreter.

	self assert: result identicalTo: interpreter nullValue
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testObjectCreationInitializesClassBeforeInstanceInitialization [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int value = 42;
	int captured = value;
}

class Test {
	static int test() {
		A a = new A();
		return a.captured;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testOrShortCircuits [

	| method result |
	method := self parseMethod: 'static int test() {
		int x = 0;
		if (true || ++x > 0) {
			return x;
		}
		return -1;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 0
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPackagePrivateMethodIsInheritedInSamePackage [

	| unit child methods |
	unit := self parseCompilationUnit: '
package example;

class Parent {
	int value() {
		return 1;
	}
}

class Child extends Parent {}'.

	interpreter classLoader addCompilationUnit: unit.

	child := interpreter classLoader
		         typeNamed: 'example.Child'
		         ifAbsent: [ self fail ].

	methods := child memberMethodsNamed: 'value'.

	self assert: methods size equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPostIncrementReturnsOldValue [

	| method result |
	method := self parseMethod: 'static int test() {
		int a = 4;
		int b = a++;
		return b * 10 + a;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 45
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPreIncrementReturnsNewValue [

	| method result |
	method := self parseMethod: 'static int test() {
		int a = 4;
		int b = ++a;
		return b * 10 + a;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 55
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPrimitiveArrayElementsHaveDefaultValue [

	| method result |
	method := self parseMethod: 'static long test() {
		long[] values = new long[1];
		return values[0];
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 0.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPrimitiveAssignmentDoesNotAlias [

	| method result |
	method := self parseMethod: 'static int test() {
		int a = 1;
		int b = a;
		a = 2;
		return b;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'accessing' }
FamixValueJavaInterpreterTest >> testPrimitiveFieldsHaveJavaDefaultValues [

	| class |
	self skip. "TODO"
	class := self parseClass: 'class Defaults {
		boolean z;
		byte b;
		short s;
		int i;
		long l;
		char c;
		float f;
		double d;

		int testBoolean() {
			return this.z ? 1 : 0;
		}

		int testByte() {
			return this.b;
		}

		int testShort() {
			return this.s;
		}

		int testInt() {
			return this.i;
		}
	}'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPrimitiveIncrementDoesNotAlias [

	| method result |
	method := self parseMethod: 'static int test() {
		int a = 1;
		int b = a;
		a++;
		return b;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPrivateInterfaceMethodIsNotInherited [

	| unit |
	unit := self parseCompilationUnit: '
interface I {
	private int value() {
		return 42;
	}
}

class A implements I {
	int test() {
		return value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	self should: [ interpreter classLoader link ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testPrivateSuperclassMethodIsNotInherited [

	| unit child methods |
	unit := self parseCompilationUnit: '
class Parent {
	private int value(int x) {
		return 1;
	}
}

class Child extends Parent {
	int value(long x) {
		return 2;
	}
}'.

	interpreter classLoader addCompilationUnit: unit.

	child := interpreter classLoader
		         typeNamed: 'Child'
		         ifAbsent: [ self fail ].

	methods := child memberMethodsNamed: 'value'.

	self assert: methods size equals: 1.
	self assert: methods first parameterTypes first name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testQualifiedPackageName [

	| unit |
	unit := self parseCompilationUnit: 'package com.example;'.

	self
		assert: unit packageDeclaration qualifiedName fullName
		equals: 'com.example'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testQualifiedTypeNameResolvesToQualifiedClass [

	| source unit class method methodInfo localType |
	self
		writeJavaSource: '
package library;

class B {
}'
		at: 'library/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unit := self parseCompilationUnit: '
class A {
	void test() {
		library.B b;
	}
}'.

	interpreter classLoader addCompilationUnit: unit.

	class := unit classDeclarations first.
	method := class declarations detect: [ :each | each name = 'test' ].
	methodInfo := interpreter classLoader executableForFASTMethod: method.

	localType := methodInfo localTypes at: 'b'.

	self assert: localType qualifiedName equals: 'library.B'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReadingUninitializedLocalFails [

	| method |
	method := self parseMethod: 'static int test() {
		int x;
		return x;
	}'.

	self should: [ interpreter execute: method ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testRecursiveConstructorInvocationIsRejected [

	| unit |
	unit := self parseCompilationUnit: '
class A {
	A() {
		this(1);
	}

	A(int value) {
		this();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	self should: [ interpreter classLoader link ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReferenceFieldsAreNull [

	| class method result |
	class := self parseClass: 'class Node {
		Node next;

		static Node test() {
			Node node = new Node();
			return node.next;
		}
	}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result identicalTo: interpreter nullValue
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReferenceNarrowingIsNotAnImplicitConversion [

	| unit parent child value loader |
	unit := self parseCompilationUnit: '
class Parent {}
class Child extends Parent {}'.

	loader := interpreter classLoader.
	loader addCompilationUnit: unit.

	parent := loader typeNamed: 'Parent' ifAbsent: [ self fail ].
	child := loader typeNamed: 'Child' ifAbsent: [ self fail ].

	value := interpreter allocateObjectOf: parent.

	self should: [ interpreter convert: value to: child ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReferenceWideningFollowsClassHierarchy [

	| unit a b c loader |
	unit := self parseCompilationUnit: '
class A {}
class B extends A {}
class C extends B {}'.

	loader := interpreter classLoader.
	loader addCompilationUnit: unit.

	a := loader typeNamed: 'A' ifAbsent: [ self fail ].
	b := loader typeNamed: 'B' ifAbsent: [ self fail ].
	c := loader typeNamed: 'C' ifAbsent: [ self fail ].

	self assert: (b canWidenTo: a).
	self assert: (c canWidenTo: a).
	self deny: (a canWidenTo: b)
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReferenceWideningFollowsInterfaceHierarchy [

	| unit a b i loader |
	unit := self parseCompilationUnit: '
interface I {}
class A implements I {}
class B extends A {}'.

	loader := interpreter classLoader.
	loader addCompilationUnit: unit.

	i := loader typeNamed: 'I' ifAbsent: [ self fail ].
	a := loader typeNamed: 'A' ifAbsent: [ self fail ].
	b := loader typeNamed: 'B' ifAbsent: [ self fail ].

	self assert: (a canWidenTo: i).
	self assert: (b canWidenTo: i)
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReferenceWideningPreservesObjectAndRuntimeType [

	| unit parent child value converted loader |
	unit := self parseCompilationUnit: '
class Parent {}
class Child extends Parent {}'.

	loader := interpreter classLoader.
	loader addCompilationUnit: unit.

	parent := loader typeNamed: 'Parent' ifAbsent: [ self fail ].
	child := loader typeNamed: 'Child' ifAbsent: [ self fail ].

	value := interpreter allocateObjectOf: child.
	converted := interpreter convert: value to: parent.

	self assert: converted identicalTo: value.
	self assert: converted runtimeType identicalTo: child
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testResolvedClassPreservesRegisteredClassInfoIdentity [

	| unit classInfo resolved |
	unit := self parseCompilationUnit: '
class Test {}

class User {
	Test value;
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	classInfo := interpreter classLoader
		             typeNamed: 'Test'
		             ifAbsent: [ self fail ].

	resolved := interpreter classLoader
		            resolveTypeNamed: 'Test'
		            in: classInfo declaringCompilationUnit.

	self assert: resolved identicalTo: classInfo.
	self assert: classInfo name equals: 'Test'.
	self assert: classInfo qualifiedName equals: 'Test'.
	self assert: classInfo loaded
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testResolvesFullyQualifiedTypeFromSourceDirectory [

	| source unit class method result |
	self
		writeJavaSource: '
package library;

class B {
	int value() {
		return 42;
	}
}'
		at: 'library/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unit := self parseCompilationUnit: '
package client;

class A {
	static int test() {
		library.B b = new library.B();
		return b.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'A' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testResolvesOnDemandImportFromSourceDirectory [

	| source unit class method result |
	self
		writeJavaSource: '
package library;

class B {
	int value() {
		return 42;
	}
}'
		at: 'library/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unit := self parseCompilationUnit: '
package client;

import library.*;

class A {
	static int test() {
		B b = new B();
		return b.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'A' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testResolvesSingleTypeImportFromSourceDirectory [

	| source unit class method result |
	self
		writeJavaSource: '
package library;

class B {
	int value() {
		return 42;
	}
}'
		at: 'library/B.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unit := self parseCompilationUnit: '
package client;

import library.B;

class A {
	static int test() {
		B b = new B();
		return b.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'A' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReturnDoesNotConvertSameType [

	| method result |
	method := self parseMethod: 'long test() {
		return 2L;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReturnInForLoop [

	| method result |
	method := self parseMethod: 'static int findFour() {
		for (int i = 0; i < 10; i++) {
			if (i == 4) {
				return i;
			}
		}
		return -1;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 4
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReturnWidensIntegerToDouble [

	| method result |
	method := self parseMethod: 'double test() {
		return 2;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'double'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testReturnWidensIntegerToLong [

	| method result |
	method := self parseMethod: 'long test() {
		return 2;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.
	self assert: result type name equals: 'long'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testSourceLoadedInterfaceIsInterfaceInfo [

	| source unit type |
	self
		writeJavaSource: '
package library;

public interface I {}'
		at: 'library/I.java'.

	source := FamixValueJavaSourceDirectory on: self sourceDirectory.
	interpreter classLoader addSource: source.

	unit := self parseCompilationUnit: '
package client;

import library.I;

class A {
	I value;
}
'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	type := interpreter classLoader
		        typeNamed: 'library.I'
		        ifAbsent: [ self fail ].

	self assert: type isInterface.
	self deny: type isClass
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticFieldCanBeReadAndWrittenThroughType [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int value;
}

class Test {
	static int test() {
		A.value = 42;
		return A.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticFieldCanBeReadThroughType [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int value;
}

class Test {
	static int test() {
		A.value = 42;
		return A.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticFieldInitializerRunsOnFirstUse [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int value = 42;
}

class Test {
	static int test() {
		return A.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticFieldInitializerSeesDefaultValueOfLaterField [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int first = second;
	static int second = 42;
}

class Test {
	static int test() {
		return A.first;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 0
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticInterfaceMethodCanBeInvokedThroughDeclaringInterface [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	static int value() {
		return 42;
	}
}

class Test {
	static int test() {
		return I.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticInterfaceMethodIsNotInheritedByImplementingClass [

	| unit |
	unit := self parseCompilationUnit: '
interface I {
	static int value() {
		return 42;
	}
}

class A implements I {}

class Test {
	static int test() {
		return A.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	self should: [ interpreter classLoader link ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticInterfaceMethodIsNotInheritedBySubinterface [

	| unit |
	unit := self parseCompilationUnit: '
interface I {
	static int value() {
		return 42;
	}
}

interface J extends I {}

class Test {
	static int test() {
		return J.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.

	self should: [ interpreter classLoader link ] raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticInterfaceMethodTriggersInterfaceInitialization [

	| unit class method result |
	unit := self parseCompilationUnit: '
interface I {
	int VALUE = 42;

	static int value() {
		return VALUE;
	}
}

class Test {
	static int test() {
		return I.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticInvocationThroughTypeName [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int value() {
		return 42;
	}
}

class Test {
	static int test() {
		return A.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticMethodInvocationTriggersClassInitialization [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	static int value = 42;

	static int getValue() {
		return value;
	}
}

class Test {
	static int test() {
		return A.getValue();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testStaticTypesOfInvocationReceiverAndArgument [

	| class testMethod methodInfo invocation |
	class := self parseClass: 'class Test {
		int choose(int value) {
			return value;
		}

		static int test() {
			Test object = new Test();
			return object.choose(42);
		}
	}'.

	testMethod := class declarations detect: [ :each |
		              each name = 'test' ].
	methodInfo := interpreter classLoader executableForFASTMethod:
		              testMethod.
	invocation := testMethod statementBlock allChildren detect: [ :each |
		              each isInvocation ].

	self
		assert: (interpreter classLoader
				 staticTypeOf: invocation receiver
				 in: methodInfo) name
		equals: 'Test'.

	self
		assert: (interpreter classLoader
				 staticTypeOf: invocation arguments first
				 in: methodInfo) name
		equals: 'int'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testSubclassDeclarationDoesNotHideDifferentSuperclassOverload [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Parent {
	int value(int x) {
		return 1;
	}
}

class Child extends Parent {
	int value(long x) {
		return 2;
	}
}

class Test {
	static int test() {
		Child child = new Child();
		return child.value(1);
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testSubclassMethodOverridesSuperclassMethodForLookup [

	| unit child inherited |
	unit := self parseCompilationUnit: '
class Parent {
	int value(int x) {
		return 1;
	}
}

class Child extends Parent {
	int value(int x) {
		return 2;
	}
}'.

	interpreter classLoader addCompilationUnit: unit.

	child := interpreter classLoader
		         typeNamed: 'Child'
		         ifAbsent: [ self fail ].

	inherited := child memberMethodsNamed: 'value'.

	self assert: inherited size equals: 1.
	self assert: inherited first declaringType identicalTo: child
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testSuperInvocationDoesNotUseVirtualDispatch [

	| unit class method object result |
	unit := self parseCompilationUnit: '
class A {
	int value() {
		return 1;
	}
}

class B extends A {
	int value() {
		return 2;
	}

	int test() {
		return super.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'B' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	object := interpreter allocateObjectOf:
		          (interpreter classLoader
			           typeNamed: 'B'
			           ifAbsent: [ self fail ]).

	result := interpreter execute: method on: object with: #(  ).

	self assert: result value equals: 1
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testSuperclassInitializationPrecedesSubclassInitialization [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value = 20;

	A() {
		value = value + 1;
	}
}

class B extends A {
	int other = value + 20;

	B() {
		other = other + 1;
	}
}

class Test {
	static int test() {
		B b = new B();
		return b.other;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testThisConstructorInvocationDoesNotRequireSuperclassZeroArgumentConstructor [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value;

	A(int value) {
		this.value = value;
	}
}

class B extends A {
	B() {
		this(42);
	}

	B(int value) {
		super(value);
	}
}

class Test {
	static int test() {
		B b = new B();
		return b.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testThisConstructorInvocationInitializesFieldsOnlyOnce [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value = 20;

	A() {
		value = value + 1;
	}

	A(int ignored) {
		this();
		value = value + 1;
	}
}

class Test {
	static int test() {
		A a = new A(0);
		return a.value;
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 22
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnallocatedArrayDimensionIsNull [

	| method result |
	method := self parseMethod: 'static int[][] test() {
		return new int[1][];
	}'.

	result := interpreter execute: method.

	self assert: result value size equals: 1.
	self
		assert: result value first value
		identicalTo: interpreter nullValue
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnaryAndBinaryMinus [

	| method result |
	method := self parseMethod: 'static int test() {
		int a = 5;
		return -a + 10;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 5
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnobservableSingleTypeImportCannotBeResolved [

	| unit |
	unit := self parseCompilationUnit: '
package client;

import library.Missing;

class A {
	Missing value;
}'.

	self
		should: [ interpreter classLoader addCompilationUnit: unit ]
		raise: FamixValueInterpreterResolveError
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnqualifiedInvocationUsesImplicitThis [

	| unit class method object result |
	unit := self parseCompilationUnit: '
class A {
	int value() {
		return 42;
	}

	int test() {
		return value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations first.
	method := class declarations detect: [ :each | each name = 'test' ].

	object := interpreter allocateObjectOf:
		          (interpreter classLoader
			           typeNamed: 'A'
			           ifAbsent: [ self fail ]).

	result := interpreter execute: method on: object with: #(  ).

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnqualifiedStaticFieldCanBeAccessed [

	| class method result |
	class := self parseClass: '
class Test {
	static int value;

	static int test() {
		value = 42;
		return value;
	}
}'.

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 42
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnrelatedDefaultInterfaceMethodsAreAmbiguous [

	| unit |
	unit := self parseCompilationUnit: '
interface I {
	default int value() {
		return 1;
	}
}

interface J {
	default int value() {
		return 2;
	}
}

class A implements I, J {}'.

	self expandFamixModelFrom: unit.

	self
		should: [
			interpreter classLoader addCompilationUnit: unit.
			interpreter classLoader link ]
		raise: Error
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testUnsuffixedFloatingLiteralIsDouble [

	| method result |
	method := self parseMethod: 'double test() {
		return 2.5;
	}'.

	result := interpreter execute: method.

	self assert: result value equals: 2.5.
	self assert: result type name equals: 'double'
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testVirtualDispatchDoesNotRedoOverloadResolution [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Argument {}

class SpecificArgument extends Argument {
}

class Parent {
	int value(Argument argument) {
		return 1;
	}
}

class Child extends Parent {
	int value(Argument argument) {
		return 2;
	}

	int value(SpecificArgument argument) {
		return 3;
	}
}

class Test {
	static int test() {
		Parent receiver = new Child();
		Argument argument = new SpecificArgument();
		return receiver.value(argument);
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testVirtualInvocationDispatchesToRuntimeOverride [

	| unit class method result |
	unit := self parseCompilationUnit: '
class Parent {
	int value() {
		return 1;
	}
}

class Child extends Parent {
	int value() {
		return 2;
	}
}

class Test {
	static int test() {
		Parent value = new Child();
		return value.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].
	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 2
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testVirtualInvocationFindsMostDerivedOverride [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value() {
		return 1;
	}
}

class B extends A {
	int value() {
		return 2;
	}
}

class C extends B {
	int value() {
		return 3;
	}
}

class Test {
	static int test() {
		A value = new C();
		return value.value();
	}
}
'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 3
]

{ #category : 'tests' }
FamixValueJavaInterpreterTest >> testVirtualInvocationSkipsClassesWithoutOverride [

	| unit class method result |
	unit := self parseCompilationUnit: '
class A {
	int value() {
		return 1;
	}
}

class B extends A {
}

class C extends B {
	int value() {
		return 3;
	}
}

class Test {
	static int test() {
		A value = new C();
		return value.value();
	}
}'.

	self expandFamixModelFrom: unit.
	interpreter classLoader addCompilationUnit: unit.
	interpreter classLoader link.

	class := unit classDeclarations detect: [ :each | each name = 'Test' ].

	method := class declarations detect: [ :each | each name = 'test' ].

	result := interpreter execute: method.

	self assert: result value equals: 3
]

{ #category : 'resources' }
FamixValueJavaInterpreterTest >> writeJavaSource: source at: relativePath [

	| file |
	file := self sourceDirectory / relativePath.
	file parent ensureCreateDirectory.
	file writeStreamDo: [ :ws | ws truncate nextPutAll: source ].
	^ file
]
