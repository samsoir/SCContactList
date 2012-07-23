//
//  SCContactGroup.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/19/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface SCContactGroup : NSObject {
    NSNumber     *_groupID;
    NSString     *_groupName;
    BOOL          _groupExistsInDatabase;
    BOOL          _groupHasChanges;
    
    NSMutableSet *_contacts;
    ABRecordRef   _groupRecord;
}

@property (nonatomic, retain) NSNumber      *groupID;
@property (nonatomic, retain) NSString      *groupName;
@property (nonatomic, readonly) NSSet       *contacts;
@property (nonatomic, readonly) ABRecordRef  groupRecord;

#pragma mark - SCContactGroup lifecycle methods

+ (SCContactGroup *)createGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithID:(NSNumber *)groupID;

- (id)initWithGroupID:(NSNumber *)groupID;

#pragma mark - SCContactGroup methods

- (BOOL)save:(NSError **)error;

- (BOOL)remove:(NSError **)error;

- (BOOL)isSaved;

- (BOOL)hasChanges;

#pragma mark - SCContactRecord methods

- (void)addContactRecord:(id)record;

- (void)removeContact:(id)record;

- (void)addContactRecords:(NSSet *)records;

- (void)removeContactRecords:(NSSet *)records;

@end
