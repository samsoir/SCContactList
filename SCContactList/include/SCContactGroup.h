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
    NSNumber         *_groupID;
    NSString         *_groupName;
    BOOL              _groupExistsInDatabase;
}

@property (nonatomic, retain) NSNumber *groupID;
@property (nonatomic, retain) NSString *groupName;

#pragma mark - SCContactGroup creation methods

+ (SCContactGroup *)contactGroupWithName:(NSString *)groupName;

+ (SCContactGroup *)contactGroupWithID:(NSNumber *)groupID;

- (id)initWithGroupID:(NSNumber *)groupID;

#pragma mark - SCContactGroup methods


#pragma mark - SCContactRecord methods

- (void)addContactRecord:(id)record;

- (void)removeContact:(id)record;

- (void)addContactRecords:(NSSet *)records;

- (void)removeContactRecords:(NSSet *)records;

@end
