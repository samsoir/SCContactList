//
//  SCContactRecord.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface SCContactRecord : NSObject {
    ABRecordRef   _ABRecord;
    BOOL          _recordHasChanges;

}

@property (nonatomic, readonly) ABRecordRef ABRecord;

#pragma mark - Record Properties

- (void)setABRecord:(ABRecordRef)record;

- (NSNumber *)recordID;

- (BOOL)recordExistsInDatabase;

@end
