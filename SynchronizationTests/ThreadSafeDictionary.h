//
//  ThreadSafeDictionary.h
//  YandexTests
//
//  Created by Mikhail Igonin on 16.03.15.
//  Copyright (c) 2015 2BC Apps. All rights reserved.
//

typedef enum
{
    TypeSynchronized = 0,
    TypeNSLock,
    TypeOSSpinLock,
    TypePTMutex,
    TypeGCDQueue,
    TypeGCDSemaphore
}SyncType;

#import <Foundation/Foundation.h>

@interface ThreadSafeDictionary : NSObject
- (instancetype)initWithType: (SyncType)type;

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (void)removeAllObjects;
- (void)setObject:(id)object forKey:(id)aKey;
@end
