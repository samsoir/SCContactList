//
//  SCContactList.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/18/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "SCContactList.h"

#ifndef kSCContactList
#define kSCContactList

#define kSCContactListContactPersonBuffer 10
#define kSCContactListContactGroupBuffer 10

#endif

@interface SCContactAddressBook : NSObject

+ (ABAddressBookRef)createAddressBookOptions:(NSDictionary *)options error:(NSError **)error;


#pragma mark - Interrogation Methods
- (BOOL)addressBookHasChanges;

- (NSArray *)getAllContacts;
- (NSArray *)getAllGroups;

#pragma mark - Persistence Methods

- (BOOL)persist:(NSError **)error;
- (void)revert;

/*!
    @method createGroupWithName:
 
    @abstract Creates a group with name supplied. If the
    group already exists then the existing group is
    returned, unless the overwrite parameter is set.
 
    @param NSString name
    @param BOOL overwrite
 
    @return id
 */
- (id)createGroupWithName:(NSString *)name
                overwrite:(BOOL)overwrite;

@end
