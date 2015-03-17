//
//  ViewController.h
//  SynchronizationTests
//
//  Created by Mikhail Igonin on 17.03.15.
//  Copyright (c) 2015 2BC Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField* iterationsCountTextField;

@property (nonatomic, weak) IBOutlet UIButton* twoBlockTestButton;
@property (nonatomic, weak) IBOutlet UIButton* lockUnlockTestButton;

@property (nonatomic, weak) IBOutlet UILabel* synchronizedLabel;
@property (nonatomic, weak) IBOutlet UILabel* nsLockLabel;
@property (nonatomic, weak) IBOutlet UILabel* osSpinLockLabel;
@property (nonatomic, weak) IBOutlet UILabel* gcdSemaphoreLabel;
@property (nonatomic, weak) IBOutlet UILabel* gcdQueueLabel;
@property (nonatomic, weak) IBOutlet UILabel* pthreadMutexLabel;

- (IBAction)twoBlocksTest:(id)sender;
- (IBAction)lockUnlockTest:(id)sender;
@end

