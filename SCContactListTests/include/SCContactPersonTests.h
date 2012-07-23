//
//  SCContactPersonTests.h
//  SCContactList
//
//  Created by Sam de Freyssinet on 7/23/12.
//  Copyright (c) 2012 Sittercity, Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <AddressBook/AddressBook.h>

@interface SCContactPersonTests : SenTestCase {
    NSMutableArray *_records;
}

@property (nonatomic, retain) NSMutableArray *records;

@end
