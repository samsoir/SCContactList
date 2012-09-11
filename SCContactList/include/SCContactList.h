//
//  Header.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 19/08/2012.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#ifndef SCContactList_Header_h
#define SCContactList_Header_h
#import <AddressBook/AddressBook.h>

#ifndef SCAddressBookCreateWithOptions
#define SCAddressBookCreate(options, error) ABAddressBookCreate()
#else
#define SCAddressBookCreate(options, error) ABAddressBookCreateWithOptions(options, error)
#endif

#import "SCContactAddressBook.h"
#import "SCContactRecord.h"
#import "SCContactPerson.h"
#import "SCContactGroup.h"

#endif