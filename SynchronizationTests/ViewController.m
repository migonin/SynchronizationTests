//
//  ViewController.m
//  SynchronizationTests
//
//  Created by Mikhail Igonin on 17.03.15.
//  Copyright (c) 2015 2BC Apps. All rights reserved.
//

#import "ViewController.h"

#import "ThreadSafeDictionary.h"

@interface ViewController () <UITextFieldDelegate>
@property (nonatomic) ThreadSafeDictionary* syncDictionary;
@property (nonatomic) ThreadSafeDictionary* nsLockDictionary;
@property (nonatomic) ThreadSafeDictionary* spinLockDictionary;
@property (nonatomic) ThreadSafeDictionary* semaphoreDictionary;
@property (nonatomic) ThreadSafeDictionary* queueDictionary;
@property (nonatomic) ThreadSafeDictionary* ptMutexDictionary;

@property (nonatomic) NSUInteger iterationsCount;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.syncDictionary = [[ThreadSafeDictionary alloc] initWithType:TypeSynchronized];
    self.nsLockDictionary = [[ThreadSafeDictionary alloc] initWithType:TypeNSLock];
    self.spinLockDictionary = [[ThreadSafeDictionary alloc] initWithType:TypeOSSpinLock];
    self.semaphoreDictionary = [[ThreadSafeDictionary alloc] initWithType:TypeGCDSemaphore];
    self.queueDictionary = [[ThreadSafeDictionary alloc] initWithType:TypeGCDQueue];
    self.ptMutexDictionary = [[ThreadSafeDictionary alloc] initWithType:TypePTMutex];
    
    self.iterationsCountTextField.delegate = self;
    
    _iterationsCount = 100000;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _iterationsCount = [textField.text integerValue];
}

- (IBAction)lockUnlockTest:(id)sender
{
    [self.view endEditing:YES];
    
    self.twoBlockTestButton.enabled = NO;
    self.lockUnlockTestButton.enabled = NO;
    
    self.synchronizedLabel.text = @"@synchronized: working...";
    self.nsLockLabel.text = @"NSLock: working...";
    self.osSpinLockLabel.text = @"OSSpinLock: working...";
    self.gcdQueueLabel.text = @"GCD Queue: working...";
    self.gcdSemaphoreLabel.text = @"GCD Semaphore: working...";
    self.pthreadMutexLabel.text = @"PThread mutex: working...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        double then, now;
        
        then = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < _iterationsCount; i++)
        {
            [_syncDictionary setObject:@(i) forKey:@(i)];
            [_syncDictionary objectForKey:@(i)];
        }
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.synchronizedLabel.text = [NSString stringWithFormat:@"@synchronized: %f sec\n", now-then];
        });
        
        
        then = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < _iterationsCount; i++)
        {
            [_nsLockDictionary setObject:@(i) forKey:@(i)];
            [_nsLockDictionary objectForKey:@(i)];
        }
        now = CFAbsoluteTimeGetCurrent();

        dispatch_async(dispatch_get_main_queue(), ^{
            self.nsLockLabel.text = [NSString stringWithFormat:@"NSLock: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < _iterationsCount; i++)
        {
            [_spinLockDictionary setObject:@(i) forKey:@(i)];
            [_spinLockDictionary objectForKey:@(i)];
        }
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.osSpinLockLabel.text = [NSString stringWithFormat:@"OSSpinLock: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < _iterationsCount; i++)
        {
            [_semaphoreDictionary setObject:@(i) forKey:@(i)];
            [_semaphoreDictionary objectForKey:@(i)];
        }
        now = CFAbsoluteTimeGetCurrent();

        dispatch_async(dispatch_get_main_queue(), ^{
            self.gcdSemaphoreLabel.text = [NSString stringWithFormat:@"GCD Semaphore: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < _iterationsCount; i++)
        {
            [_queueDictionary setObject:@(i) forKey:@(i)];
            [_queueDictionary objectForKey:@(i)];
        }
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gcdQueueLabel.text = [NSString stringWithFormat:@"GCD Queue: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        for (NSUInteger i = 0; i < _iterationsCount; i++)
        {
            [_ptMutexDictionary setObject:@(i) forKey:@(i)];
            [_ptMutexDictionary objectForKey:@(i)];
        }
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pthreadMutexLabel.text = [NSString stringWithFormat:@"PThread mutex: %f sec\n", now-then];
            
            self.twoBlockTestButton.enabled = YES;
            self.lockUnlockTestButton.enabled = YES;
        });

    });
}

- (IBAction)twoBlocksTest:(id)sender
{
    [self.view endEditing:YES];
    
    self.twoBlockTestButton.enabled = NO;
    self.lockUnlockTestButton.enabled = NO;
    
    self.synchronizedLabel.text = @"@synchronized: working...";
    self.nsLockLabel.text = @"NSLock: working...";
    self.osSpinLockLabel.text = @"OSSpinLock: working...";
    self.gcdQueueLabel.text = @"GCD Queue: working...";
    self.gcdSemaphoreLabel.text = @"GCD Semaphore: working...";
    self.pthreadMutexLabel.text = @"PThread mutex: working...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        double then, now;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        then = CFAbsoluteTimeGetCurrent();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_syncDictionary setObject:@(i) forKey:@(i)];
                [_syncDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_syncDictionary setObject:@(i) forKey:@(i)];
                [_syncDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.synchronizedLabel.text = [NSString stringWithFormat:@"@synchronized: %f sec\n", now-then];
        });
        
        
        then = CFAbsoluteTimeGetCurrent();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_nsLockDictionary setObject:@(i) forKey:@(i)];
                [_nsLockDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_nsLockDictionary setObject:@(i) forKey:@(i)];
                [_nsLockDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nsLockLabel.text = [NSString stringWithFormat:@"NSLock: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_spinLockDictionary setObject:@(i) forKey:@(i)];
                [_spinLockDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_spinLockDictionary setObject:@(i) forKey:@(i)];
                [_spinLockDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.osSpinLockLabel.text = [NSString stringWithFormat:@"OSSpinLock: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_semaphoreDictionary setObject:@(i) forKey:@(i)];
                [_semaphoreDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_semaphoreDictionary setObject:@(i) forKey:@(i)];
                [_semaphoreDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gcdSemaphoreLabel.text = [NSString stringWithFormat:@"GCD Semaphore: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_queueDictionary setObject:@(i) forKey:@(i)];
                [_queueDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_queueDictionary setObject:@(i) forKey:@(i)];
                [_queueDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gcdQueueLabel.text = [NSString stringWithFormat:@"GCD Queue: %f sec\n", now-then];
        });
        
        then = CFAbsoluteTimeGetCurrent();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_ptMutexDictionary setObject:@(i) forKey:@(i)];
                [_ptMutexDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSUInteger i = 0; i < _iterationsCount; i++)
            {
                [_ptMutexDictionary setObject:@(i) forKey:@(i)];
                [_ptMutexDictionary objectForKey:@(i)];
            }
            
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        now = CFAbsoluteTimeGetCurrent();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pthreadMutexLabel.text = [NSString stringWithFormat:@"PThread mutex: %f sec\n", now-then];
            
            self.twoBlockTestButton.enabled = YES;
            self.lockUnlockTestButton.enabled = YES;
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
