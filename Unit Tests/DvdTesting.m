//
//  DvdTesting.m
//  DVDKit
//
//  Created by sdickson on 12/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DvdTesting.h"
#import <DVDKit/DVDKit.h>

@implementation DvdTesting

- (void) testDvd
{
    DVDVirtualMachine* vm = [[DVDVirtualMachine alloc] initWithDataSource:self];
	
	// 7100000D43210000 | g[13] = 0x4321
	uint8_t _i00001[] = { 0x71, 0x00, 0x00, 0x0D, 0x43, 0x21, 0x00, 0x00 };
	DVDCommand* _c00001 = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:_i00001 length:8]];
	NSString* _s00001 = [_c00001 description];
	// TODO: Assert that _s00001 == "      7100000d43210000 | g[13] = 0x4321 ("C!")"
	[_c00001 executeAgainstVirtualMachine:vm];
	// TODO: Assert that the value of the vm's g13 is 0x4321.
	
    
}

- (void) setUp
{
    f1 = 3.0;
    f2 = 3.0;
}

- (void) testAddition
{
    STAssertTrue (f1 + f2 == 5.0, @"%f + %f should equal 5.0", f1, f2);
}

@end
