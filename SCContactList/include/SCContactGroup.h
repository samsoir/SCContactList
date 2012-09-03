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

@interface SCContactGroup : SCContactRecord <SCContactRecordPersistence> {

    NSString     *_groupName;
    
    NSMutableSet *_contacts;
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

- (NSSet *)contacts;
- (void)addContactRecord:(id)record;
- (void)removeContact:(id)record;
- (void)addContactRecords:(NSSet *)records;
- (void)removeContactRecords:(NSSet *)records;

@end
