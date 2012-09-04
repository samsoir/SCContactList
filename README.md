# SCContactList

By Sam de Freyssinet, Sittercity, Inc.

 * Visit [Sittercity](http://www.sittercity.com)
 * Follow [@samsoir](http://www.twitter.com/samsoir) on Twitter

iOS Framework to provide an OO interface to ABAddressBook

# Introduction

SCContactList is an object-oriented interface to the ABAddressBook core
library. SCContactList provides a simple façade interface to the C based Apple
Address Book framework. All persistence and read operations are performed
atomically, allowing for SCContactRecord objects to be passed between threads
and/or operations safely.

Included in the library are four core models;

 * SCContactAddressBook (ABAddressBookRef)
 * SCContactRecord (ABRecordRef)
 * SCContactGroup (ABRecordRef of type ABGroupRecord)
 * SCContactPerson (ABRecordRef of type ABPersonRecord)

# Getting Started

SCContactList is a static library that must be compiled before it can be used in
other projects. The compilation process provides the compiled static library 
_libSCContactList.a_ and five headers to include.

Once the library is compiled, add the static library and headers to your Xcode
project, ensuring the headers are within the projects header search paths.

Before trying to use the library, also ensure the Xcode project using
SCContactList also has the _AddressBook.framework_ framework linked at compile
time.

To use the library, include the following header;

```ObjC
#import "SCContactList.h"
```

# Licence

SCContactList is released under an open source 
[ISC License](http://opensource.org/licenses/isc-license.txt) (which is 
included in the source code).


