//
//  SCContactRecord.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "SCContactList.h"

#ifndef kSCContactRecord
#define kSCContactRecord @"SCContactRecord"

#define kSCContactRecordReadError 10000

#define kSCContactRecordDeleteError 10003
#define kSCContactRecrodDeleteErrorKey @"errorMessage"
#define kSCContactRecordKeyForUnkeyedEntry @"_$!<Facebook>!$_"

#endif

#ifndef __SCContactRecordPersistence__
#define __SCContactRecordPersistence__

@protocol SCContactRecordPersistence <NSObject>

#pragma mark - SCContactRecordPersistence Methods

- (BOOL)readFromRecordRef:(ABRecordRef *)recordRef error:(NSError **)error;
- (ABRecordRef)addressBook:(ABAddressBookRef)addressBook getABRecordWithID:(ABRecordID)recordID;

- (BOOL)createRecord:(ABRecordID)recordID error:(NSError **)error;
- (BOOL)readRecord:(ABRecordID)recordID error:(NSError **)error;
- (BOOL)updateRecord:(ABRecordID)recordID error:(NSError **)error;
- (BOOL)deleteRecord:(ABRecordID)recordID error:(NSError **)error;

@end

#endif

@interface SCContactRecord : NSObject <SCContactRecordPersistence> {
    ABRecordID           _ABRecordID;
    NSMutableDictionary *_changesToModel;
}

@property (nonatomic, assign) ABRecordID ABRecordID;

- (id)initWithABRecordID:(ABRecordID)recordID;

#pragma mark - Record Properties

- (BOOL)recordExistsInDatabase;

- (NSDictionary *)changesRequiringPersistence;

- (BOOL)hasChanges;

- (BOOL)isSaved;

- (void)_resetState;

#pragma mark - Key/Value Observing Methods

- (NSArray *)objectKeysToObserve;

- (void)initializeKeyValueObserving:(NSArray *)keysToObserve options:(int)options;

- (void)deinitializeKeyValueObserving:(NSArray *)keysToUnobserve;

#pragma mark - SCContactRecord setup methods

- (void)setProperties:(ABPropertyID *)properties withAccessorMethods:(SEL *)accessorMethods fromRecord:(ABRecordRef)record numberOfProperties:(int)count;
- (NSMutableDictionary *)mutableDictionaryFromMultiValueProperty:(ABPropertyID)property record:(ABRecordRef)record;

#pragma mark - SCContactRecordPersistence Methods

- (ABRecordRef)addressBook:(ABAddressBookRef)addressBook getABRecordWithID:(ABRecordID)recordID;
- (BOOL)deleteRecord:(ABRecordID)recordID error:(NSError **)error;

@end
