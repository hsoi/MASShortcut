#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"

@interface MASShortcutUserDefaultsHotKey : NSObject {
    
    NSString *_userDefaultsKey;
    void (^_handler)();
    id _monitor;
    NSString *_observableKeyPath;
}

@property (nonatomic, copy) NSString *userDefaultsKey;
@property (nonatomic, copy) void (^handler)();
@property (nonatomic, retain) id monitor;
@property (nonatomic, copy) NSString* observableKeyPath;

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;

@end

#pragma mark -

@implementation MASShortcut (UserDefaults)

+ (NSMutableDictionary *)registeredUserDefaultsHotKeys
{
    static NSMutableDictionary *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NSMutableDictionary alloc] init];
    });
    return shared;
}

+ (void)registerGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler;
{
    MASShortcutUserDefaultsHotKey *hotKey = [[MASShortcutUserDefaultsHotKey alloc] initWithUserDefaultsKey:userDefaultsKey handler:handler]; // yes, don't autorelease.
    [[self registeredUserDefaultsHotKeys] setObject:hotKey forKey:userDefaultsKey];
}

+ (void)unregisterGlobalShortcutWithUserDefaultsKey:(NSString *)userDefaultsKey
{
    NSMutableDictionary *registeredHotKeys = [self registeredUserDefaultsHotKeys];
    [registeredHotKeys removeObjectForKey:userDefaultsKey];
}

+ (void)setGlobalShortcut:(MASShortcut *)shortcut forUserDefaultsKey:(NSString *)userDefaultsKey
{
    NSData *shortcutData = shortcut.data;
    if (shortcutData)
        [[NSUserDefaults standardUserDefaults] setObject:shortcutData forKey:userDefaultsKey];
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
}

@end

#pragma mark -

@implementation MASShortcutUserDefaultsHotKey

@synthesize userDefaultsKey = _userDefaultsKey;
@synthesize handler = _handler;
@synthesize monitor = _monitor;
@synthesize observableKeyPath = _observableKeyPath;


void *MASShortcutUserDefaultsContext = &MASShortcutUserDefaultsContext;

- (id)initWithUserDefaultsKey:(NSString *)userDefaultsKey handler:(void (^)())handler
{
    self = [super init];
    if (self) {
        _userDefaultsKey = [userDefaultsKey copy];
        _handler = [handler copy];
        _observableKeyPath = [[@"values." stringByAppendingString:_userDefaultsKey] copy];
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:_observableKeyPath options:NSKeyValueObservingOptionInitial context:MASShortcutUserDefaultsContext];
    }
    return self;
}

- (void)dealloc
{
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:_observableKeyPath context:MASShortcutUserDefaultsContext];
    [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
 
    [_userDefaultsKey release];
    [_handler release];
    [_observableKeyPath release];
    [_monitor release];
    
    [super dealloc];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == MASShortcutUserDefaultsContext) {
        [MASShortcut removeGlobalHotkeyMonitor:self.monitor];
        [self installHotKeyFromUserDefaults];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)installHotKeyFromUserDefaults
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:_userDefaultsKey];
    MASShortcut *shortcut = [MASShortcut shortcutWithData:data];
    if (shortcut == nil) return;
    self.monitor = [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:self.handler];
}

@end
