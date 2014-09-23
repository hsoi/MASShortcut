#import <AppKit/AppKit.h>

@class MASShortcut;

typedef enum {
    MASShortcutViewAppearanceDefault = 0,  // Height = 19 px
    MASShortcutViewAppearanceTexturedRect, // Height = 25 px
    MASShortcutViewAppearanceRounded       // Height = 43 px
} MASShortcutViewAppearance;

@interface MASShortcutView : NSView {
    NSButtonCell *_shortcutCell;
    NSInteger _shortcutToolTipTag;
    NSInteger _hintToolTipTag;
    NSTrackingArea *_hintArea;
    BOOL _enabled;
    BOOL _hinting;
    NSString* _shortcutPlaceholder;
    MASShortcut* _shortcutValue;
    BOOL _recording;
    void (^_shortcutValueChange)(MASShortcutView *sender);
    MASShortcutViewAppearance _appearance;
}

@property (nonatomic, retain) MASShortcut *shortcutValue;
@property (nonatomic, getter = isRecording) BOOL recording;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) void (^shortcutValueChange)(MASShortcutView *sender);
@property (nonatomic) MASShortcutViewAppearance appearance;

/// Returns custom class for drawing control.
+ (Class)shortcutCellClass;

@end
