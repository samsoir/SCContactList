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
    ABRecordRef          _ABRecord;
    NSMutableDictionary *_changesToModel;
}

@property (nonatomic, readonly) ABRecordRef ABRecord;

#pragma mark - Record Properties

- (void)setABRecord:(ABRecordRef)record;

- (NSNumber *)recordID;

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

@end

@protocol SCContactRecordPersistence <NSObject>

#pragma mark - SCContactRecordPersistence Methods

- (BOOL)loadRecord:(ABRecordRef)record error:(NSError **)error;
- (BOOL)saveRecord:(ABRecordRef)record error:(NSError **)error;
- (BOOL)deleteRecord:(ABRecordRef)record error:(NSError **)error;

@end
