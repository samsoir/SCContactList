//
//  SCContactGroup.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "SCContactList.h"

#ifndef __SCContactGroup__
#define __SCContactGroup__

#define kSCContactGroupMutableSetCapacity 10

#endif

@class SCContactPerson;

@interface SCContactGroup : SCContactRecord <SCContactRecordPersistence> {

    NSString     *_groupName;
    
    NSMutableSet *_contacts;
    NSMutableSet *_removedContacts;
     
    BOOL          _contactsLoaded;
    BOOL          _contactsChanged;
}

@property (nonatomic, retain) NSString       *groupName;

#pragma mark - SCContactGroup lifecycle methods

+ (SCContactGroup *)createGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithID:(ABRecordID)groupID;

- (id)initWithABRecordID:(ABRecordID)recordID;

#pragma mark - SCContactRecordPersistence Methods

- (BOOL)readFromRecordRef:(ABRecordRef)recordRef error:(NSError **)error;
- (ABRecordRef)addressBook:(ABAddressBookRef)addressBook getABRecordWithID:(ABRecordID)recordID;

- (BOOL)contactsLoaded;
- (BOOL)contactsChanged;
- (BOOL)loadContacts:(NSError **)error;
- (NSSet *)filterContactsSetWithPredicate:(NSPredicate *)predicate;

- (NSSet *)contacts;
- (void)addContactRecord:(SCContactPerson *)record;
- (void)removeContact:(SCContactPerson *)record;
- (void)addContactRecords:(NSSet *)records;
- (void)removeContactRecords:(NSSet *)records;

@end
