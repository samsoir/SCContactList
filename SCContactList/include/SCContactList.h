//
//  SCContactList.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/18/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface SCContactList : NSObject {
    NSArray *_contactRecords;
}

@property (nonatomic, retain) NSArray *contactRecords;

/*!
    @method initializeContactsDatabase
 
    @abstract Initializes the locale contacts database
    copied from the system Contacts database.
 
    @return BOOL yes if the database copied successfully
 */
- (BOOL)initializeContactsDatabase;

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
