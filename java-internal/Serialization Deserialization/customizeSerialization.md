# Customize Serialization
When you use Serializable interface you don't have much control over the process of serialization which causes issues of performance and maintainability. So in many cases you might like to have more control over what and how to serialize or deserialize the object. One way to do that is using Externalize interface, and is preferrabily the better one, which we will discuss on next page. Another way is by implementing the methods readResolve(), writeReplace(), readResolve(), writeReplace() in Serializable class. 
When JVM serialize/deserialize object of your class, if it finds thse methods it will automatically invoke them. These methods are sometimes also called as magic methods of Serialization. Lets have a closer look at them to understand their role in Serialization.

## Methods Invoked during Serialization
During serialization, if implemented, first writeReplace is invoked and then writeObject.

## Methods invoked during deserialization
During deserialization first readObject() is called and then readResolve().

### private void writeObject(ObjectOutputStream out) throws IOException;
writeObject allows you to control what fields/data would be serialized. 
Normally, first you call out.defaultWriteObject method for invoking default mechanism of serialization. After that mention more data that you want to serialize like fields from superclass or transient variables.

### private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException;
This method is similar to writeObject except its used during deserialization. 
Here also, first you call in.defaultReadObject to invoke the default mechanism for restoring the object. Then you can read extra data that you saved during serialization. Data should be read in exactly the same order as it is written in the stream. 

Note: Whenever implemented, readObject and writeObject methods must be declared private. This is because we don't want these methods to be overridden by subclasses. Instead, each class should have its own implementation of readObject/writeObject. JVM can call the private methos also, but no external class would be able to do that.
ObjectInputStream/ObjectOutputStreamOutput classes also have readObject/writeObject methods, which are used in normal serialization/deserialization. These readObject/writeObject methods that you declare inside your class are not the same, these are special methods. 
Serialization of an object can be prevented by implementing writeObject and readObject methods that throw the NotSerializableException.

### Why to override readObject and writeObject
This is done for below reaons:
Backward compatibility i.e. keep Serialization stable over multiple code revisions.
Performance Improvement.
To serialize transient fields or super class members.
However, using externalizable interface is better option to achieve the above mentioned purpose. 

### Object writeReplace() throws ObjectStreamException
writeReplace method allows you to serialize a completely different object, instead of the original one. Though both objects should be compatible.

### Object readResolve() throws ObjectStreamException
readResolve method allows to replace the de-serialized object by another object of your choice. so this object replaces the object returned by readObject. The two objects should be of compatilbe type in all uses, otherwise a ClassCastException will be thrown when the type mismatch is discovered. 
The readResolve method is used when you need to return an existing object (say in case of singleton). So you can implement this method and return the same singleton instance from it. This way you can ensure singleton contract. 


## Customize via Externalizable
you can write your own serialization logic by implementing Externalizable interface and overriding it’s methods writeExternal() and readExternal()

```
public void writeExternal(ObjectOutput out) throws IOException {
    out.writeInt(fieldOne);
    out.writeUTF(fieldTwo);
    out.writeBoolean(fieldThree);
}
```

```
public void writeExternal(ObjectOutput out) throws IOException {
    out.writeInt(fieldOne);
    out.writeUTF(fieldTwo);
    out.writeBoolean(fieldThree);
}
```

## Reference
http://www.bamals.com/core-java/tutorials/customize-serialization-override-readOjbect-writeObject-readResolve-writeReplace.php

