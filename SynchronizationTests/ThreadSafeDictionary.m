//
//  ThreadSafeDictionary.m
//  YandexTests
//
//  Created by Mikhail Igonin on 16.03.15.
//  Copyright (c) 2015 2BC Apps. All rights reserved.
//

#import "ThreadSafeDictionary.h"

#import <libkern/OSAtomic.h>
#import <pthread.h>

@interface ThreadSafeDictionary()
{
    SyncType type;
    NSMutableDictionary* dictionary;
    
    NSLock* nsLock;
    OSSpinLock osSpinLock;
    dispatch_queue_t queue;
    dispatch_semaphore_t semaphore;
    
    pthread_mutex_t ptMutex;
}
@end

@implementation ThreadSafeDictionary

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        type = TypeSynchronized;
        
        dictionary = [NSMutableDictionary dictionary];
        nsLock = [[NSLock alloc] init];
        osSpinLock = OS_SPINLOCK_INIT;
        
        queue = dispatch_queue_create("com.2bc.synctest", DISPATCH_QUEUE_SERIAL);
        semaphore = dispatch_semaphore_create(1);
        
        pthread_mutex_init(&ptMutex, NULL);
    }
    
    return self;
}

- (instancetype)initWithType:(SyncType)aType
{
    self = [self init];
    
    if (self)
    {
        type = aType;
    }
    
    return self;
}


- (NSUInteger)count
{
    __block NSUInteger count = 0;
    
    switch (type)
    {
        case TypeSynchronized:
        {
            @synchronized(dictionary)
            {
                count =  dictionary.count;
            }
            
            break;
        }

        case TypeNSLock:
        {
            [nsLock lock];
            count = dictionary.count;
            [nsLock unlock];
            
            break;
        }
            
        case TypeOSSpinLock:
        {
            OSSpinLockLock(&osSpinLock);
            count = dictionary.count;
            OSSpinLockUnlock(&osSpinLock);
            
            break;
        }
            
        case TypeGCDQueue:
        {
            dispatch_sync(queue, ^{
                count = dictionary.count;
            });
            
            break;
        }
            
        case TypePTMutex:
        {
            pthread_mutex_lock(&ptMutex);
            count = dictionary.count;
            pthread_mutex_unlock(&ptMutex);
        }
            
        case TypeGCDSemaphore:
        {

            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            count = dictionary.count;
            dispatch_semaphore_signal(semaphore);
            
            break;
        }
    }
    
    return count;
}

- (id)objectForKey:(id)aKey
{
    __block id object = nil;
    
    if (aKey != nil && [aKey conformsToProtocol:@protocol(NSCopying)])
    {
        switch (type)
        {
            case TypeSynchronized:
            {
                @synchronized(dictionary)
                {
                    object = [dictionary objectForKey:aKey];
                }
                
                break;
            }
                
            case TypeNSLock:
            {
                [nsLock lock];
                object = [dictionary objectForKey:aKey];
                [nsLock unlock];
                
                break;
            }
                
            case TypeOSSpinLock:
            {
                OSSpinLockLock(&osSpinLock);
                object = [dictionary objectForKey:aKey];
                OSSpinLockUnlock(&osSpinLock);
                
                break;
            }
                
            case TypeGCDQueue:
            {
                dispatch_sync(queue, ^{
                    object = [dictionary objectForKey:aKey];
                });
                
                break;
            }
                
            case TypePTMutex:
            {
                pthread_mutex_lock(&ptMutex);
                object = [dictionary objectForKey:aKey];
                pthread_mutex_unlock(&ptMutex);
            }

                
            case TypeGCDSemaphore:
            {
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                object = [dictionary objectForKey:aKey];
                dispatch_semaphore_signal(semaphore);
                
                break;
            }
        }
    }
    
    return object;
}

- (void)setObject:(id)object forKey:(id)aKey
{
    
    if (object != nil && aKey != nil && [aKey conformsToProtocol:@protocol(NSCopying)])
    {
        switch (type)
        {
            case TypeSynchronized:
            {
                @synchronized(dictionary)
                {
                    [dictionary setObject:object forKey:aKey];
                }
                
                break;
            }
                
            case TypeNSLock:
            {
                [nsLock lock];
                [dictionary setObject:object forKey:aKey];
                [nsLock unlock];
                
                break;
            }
                
            case TypePTMutex:
            {
                pthread_mutex_lock(&ptMutex);
                [dictionary setObject:object forKey:aKey];
                pthread_mutex_unlock(&ptMutex);
            }
                
            case TypeOSSpinLock:
            {
                OSSpinLockLock(&osSpinLock);
                [dictionary setObject:object forKey:aKey];
                OSSpinLockUnlock(&osSpinLock);
                
                break;
            }
                
            case TypeGCDQueue:
            {
                dispatch_sync(queue, ^{
                    [dictionary setObject:object forKey:aKey];
                });
                
                break;
            }
                
            case TypeGCDSemaphore:
            {
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                [dictionary setObject:object forKey:aKey];
                dispatch_semaphore_signal(semaphore);
                
                break;
            }
        }
    }

}

- (void)removeAllObjects
{
    switch (type)
    {
        case TypeSynchronized:
        {
            @synchronized(dictionary)
            {
                [dictionary removeAllObjects];
            }
            
            break;
        }
            
        case TypeNSLock:
        {
            [nsLock lock];
            [dictionary removeAllObjects];
            [nsLock unlock];
            
            break;
        }
            
        case TypePTMutex:
        {
            pthread_mutex_lock(&ptMutex);
            [dictionary removeAllObjects];
            pthread_mutex_unlock(&ptMutex);
        }
            
        case TypeOSSpinLock:
        {
            OSSpinLockLock(&osSpinLock);
            [dictionary removeAllObjects];
            OSSpinLockUnlock(&osSpinLock);
            
            break;
        }
            
        case TypeGCDQueue:
        {
            dispatch_sync(queue, ^{
                [dictionary removeAllObjects];
            });
            
            break;
        }
            
        case TypeGCDSemaphore:
        {
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [dictionary removeAllObjects];
            dispatch_semaphore_signal(semaphore);
            
            break;
        }
    }

}
@end
