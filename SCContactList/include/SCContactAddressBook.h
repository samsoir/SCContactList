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

#ifndef __SCContactAddressBook__
#define __SCContactAddressBook__

#define kSCContactListContactPersonBuffer 10
#define kSCContactListContactGroupBuffer  10

#endif

typedef CF_ENUM(CFIndex, SCContactListAuthorizationStatus) {
    kSCContactListAuthorizationStatusNotDetermined = 0,
    kSCContactListAuthorizationStatusRestricted,
    kSCContactListAuthorizationStatusDenied,
    kSCContactListAuthorizationStatusAuthorized
};

extern NSString *const SCContactAddressBookAuthorizationNotification;

@interface SCContactAddressBook : NSObject

#pragma mark - AddressBook Access

+ (void)requestAddressBookAuthorization:(void (^)(BOOL granted, NSError *error))completionHandler;
+ (SCContactListAuthorizationStatus)addressBookAuthorizationStatus;

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
