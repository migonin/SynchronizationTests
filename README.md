# iOS synchronization tests
Actually there are several synchronization approaches in iOS. Let's see which is most effective.

Test preconditions is simple - shared NSMutableDictionary.
Synchronization primitives:
* @synchronized
* NSLock
* OSSpinLock
* GCD semaphore
* GCD serial queu
* pthread mutex

## Lock-unlock test
In this test I just lock dictionary, do some work with it and unlock it for 1 000 000 times.

![alt tag](https://raw.githubusercontent.com/migonin/SynchronizationTests/master/SynchronizationTests/Diagrams/lockUnlock.png) 

## Two concurrent blocks test
In this test things get real: I lock shared dictionary, do some work and unlock it from two concurrent blocks for 100 000 times each.

![alt tag](https://raw.githubusercontent.com/migonin/SynchronizationTests/master/SynchronizationTests/Diagrams/twoBlocks.png) 
