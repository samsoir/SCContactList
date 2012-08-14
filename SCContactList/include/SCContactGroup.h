//
//  SCContactGroup.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "SCContactRecord.h"

@interface SCContactGroup : SCContactRecord {
    NSNumber     *_groupID;
    NSString     *_groupName;
    
    NSMutableSet *_contacts;
}

@property (nonatomic, retain) NSNumber      *groupID;
@property (nonatomic, retain) NSString      *groupName;
@property (nonatomic, readonly) NSSet       *contacts;

#pragma mark - SCContactGroup lifecycle methods

+ (SCContactGroup *)createGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithID:(NSNumber *)groupID;

- (id)initWithGroupID:(NSNumber *)groupID;

#pragma mark - SCContactGroup methods

- (BOOL)save:(NSError **)error;

- (BOOL)remove:(NSError **)error;

#pragma mark - SCContactRecord methods

- (void)addContactRecord:(id)record;

- (void)removeContact:(id)record;

- (void)addContactRecords:(NSSet *)records;

- (void)removeContactRecords:(NSSet *)records;

@end
