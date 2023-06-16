"
A representation of Java date types like `java.util.Date` or `java.sql.Timestamp`.
This family of types has a special serialization format: all attributes are transient, and only a `long` is used to measure the epoch time.
"
Class {
	#name : #FamixValueJavaDate,
	#superclass : #FamixValueSpecialType,
	#category : #'Famix-Value-Types'
}
