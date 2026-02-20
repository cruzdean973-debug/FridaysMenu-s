// FridaysMenu.m
// Animal Company Companion — "Friday's Menu"
// Tabs: Player Mods | Trolling | Exploits | Spawning | Settings
//
// Compile:
//   clang -shared -o FridaysMenu.dylib FridaysMenu.m \
//         -framework UIKit -framework Foundation \
//         -framework QuartzCore -fobjc-arc \
//         -target arm64-apple-ios14.0 \
//         -isysroot /path/to/iPhoneOS.sdk
//
// Plist target: com.woosterGames.animalCompany

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

// ═══════════════════════════════════════════════════════
// THEME — Sunny & Vibrant
// ═══════════════════════════════════════════════════════

#define W_SUN       [UIColor colorWithRed:1.0  green:0.85 blue:0.1  alpha:1.0]
#define W_ORANGE    [UIColor colorWithRed:1.0  green:0.55 blue:0.1  alpha:1.0]
#define W_PINK      [UIColor colorWithRed:1.0  green:0.35 blue:0.65 alpha:1.0]
#define W_MINT      [UIColor colorWithRed:0.2  green:0.95 blue:0.65 alpha:1.0]
#define W_SKY       [UIColor colorWithRed:0.3  green:0.8  blue:1.0  alpha:1.0]
#define W_PURPLE    [UIColor colorWithRed:0.7  green:0.3  blue:1.0  alpha:1.0]
#define W_DARK      [UIColor colorWithRed:0.06 green:0.04 blue:0.1  alpha:1.0]
#define W_DARK2     [UIColor colorWithRed:0.1  green:0.07 blue:0.16 alpha:1.0]
#define W_BTN       [UIColor colorWithRed:0.12 green:0.08 blue:0.2  alpha:0.92]
#define W_TEXT      [UIColor colorWithRed:1.0  green:0.97 blue:0.85 alpha:1.0]
#define W_SUBTEXT   [UIColor colorWithRed:0.8  green:0.75 blue:1.0  alpha:0.85]

// ═══════════════════════════════════════════════════════
// SHARED SPAWN LOCATION STATE
// ═══════════════════════════════════════════════════════

static NSString *g_locName = @"Spawn";
static float g_x = 0.0f, g_y = 6.0f, g_z = -10.0f;

void sendCmd(NSString *cmd) {
    NSLog(@"[FridaysMenu] %@", cmd);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"ACCompanionSpawnCommand"
                      object:nil
                    userInfo:@{@"command": cmd}];
}

void wSpawnItem(NSString *item, NSInteger qty) {
    sendCmd([NSString stringWithFormat:@"hey ai spawn %@ %ld %.2f %.2f %.2f",
             item, (long)qty, g_x, g_y, g_z]);
}

void wSpawnMob(NSString *mob) {
    sendCmd([NSString stringWithFormat:@"hey ai spawn mob %@ %.2f %.2f %.2f",
             mob, g_x, g_y, g_z]);
}

// ═══════════════════════════════════════════════════════
// FLOATING PARTICLES BACKGROUND
// ═══════════════════════════════════════════════════════

@interface WParticleLayer : UIView @end
@implementation WParticleLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;

        // Floating flower/sun particles
        NSArray *emojis = @[@"🌸", @"✨", @"🌟", @"🌼", @"💫", @"🌺", @"⭐", @"🌻"];
        NSArray *colors = @[
            W_SUN, W_ORANGE, W_PINK, W_MINT, W_SKY, W_PURPLE,
            [UIColor colorWithRed:1.0 green:0.9 blue:0.3 alpha:0.9],
            [UIColor colorWithRed:0.5 green:1.0 blue:0.7 alpha:0.8],
        ];

        // Small glowing dots
        for (int i = 0; i < 45; i++) {
            CGFloat sz = (arc4random_uniform(4) + 2);
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(
                arc4random_uniform((uint32_t)frame.size.width),
                arc4random_uniform((uint32_t)frame.size.height), sz, sz)];
            dot.layer.cornerRadius = sz / 2;
            dot.backgroundColor = colors[i % colors.count];
            [self addSubview:dot];

            // Twinkle
            CABasicAnimation *twinkle = [CABasicAnimation animationWithKeyPath:@"opacity"];
            twinkle.fromValue = @(0.05); twinkle.toValue = @(1.0);
            twinkle.duration = 0.5 + (arc4random_uniform(30) / 10.0);
            twinkle.autoreverses = YES; twinkle.repeatCount = HUGE_VALF;
            twinkle.beginTime = CACurrentMediaTime() + (arc4random_uniform(40) / 10.0);
            [dot.layer addAnimation:twinkle forKey:@"twinkle"];

            // Float up
            CABasicAnimation *floatUp = [CABasicAnimation animationWithKeyPath:@"position.y"];
            floatUp.fromValue = @(dot.center.y);
            floatUp.toValue = @(dot.center.y - (arc4random_uniform(20) + 8));
            floatUp.duration = 2.0 + (arc4random_uniform(30) / 10.0);
            floatUp.autoreverses = YES; floatUp.repeatCount = HUGE_VALF;
            floatUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [dot.layer addAnimation:floatUp forKey:@"float"];
        }

        // Emoji particles
        for (int i = 0; i < 8; i++) {
            UILabel *emoji = [[UILabel alloc] init];
            emoji.text = emojis[i % emojis.count];
            emoji.font = [UIFont systemFontOfSize:10 + arc4random_uniform(8)];
            [emoji sizeToFit];
            emoji.center = CGPointMake(
                arc4random_uniform((uint32_t)frame.size.width),
                arc4random_uniform((uint32_t)frame.size.height));
            emoji.alpha = 0.3 + (arc4random_uniform(5) / 10.0);
            [self addSubview:emoji];

            CABasicAnimation *drift = [CABasicAnimation animationWithKeyPath:@"position.y"];
            drift.fromValue = @(emoji.center.y);
            drift.toValue = @(emoji.center.y - 15 - arc4random_uniform(15));
            drift.duration = 3.0 + arc4random_uniform(3);
            drift.autoreverses = YES; drift.repeatCount = HUGE_VALF;
            drift.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [emoji.layer addAnimation:drift forKey:@"drift"];
        }
    }
    return self;
}
@end

// ═══════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════

UILabel *wSectionHeader(NSString *title, CGFloat y, CGFloat w) {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(12, y, w - 24, 18)];
    l.text = title;
    l.textColor = W_MINT;
    l.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:10] ?: [UIFont boldSystemFontOfSize:10];
    l.layer.shadowColor = W_MINT.CGColor;
    l.layer.shadowOpacity = 0.8; l.layer.shadowRadius = 4;
    return l;
}

UIView *wDivider(CGFloat y, CGFloat w) {
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(12, y, w - 24, 1)];
    CAGradientLayer *g = [CAGradientLayer layer]; g.frame = div.bounds;
    g.colors = @[(id)[UIColor clearColor].CGColor,
                 (id)[UIColor colorWithRed:1.0 green:0.85 blue:0.1 alpha:0.5].CGColor,
                 (id)[UIColor clearColor].CGColor];
    g.startPoint = CGPointMake(0, 0.5); g.endPoint = CGPointMake(1, 0.5);
    [div.layer addSublayer:g];
    return div;
}

UIButton *wBtn(NSString *title, UIColor *accent) {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:W_TEXT forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    b.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    b.backgroundColor = W_BTN;
    b.layer.cornerRadius = 12;
    b.layer.borderWidth = 1.0;
    b.layer.borderColor = (accent ?: W_SUN).CGColor;
    b.layer.shadowColor = (accent ?: W_SUN).CGColor;
    b.layer.shadowOpacity = 0.45; b.layer.shadowRadius = 6;
    b.layer.shadowOffset = CGSizeMake(0, 2);
    return b;
}

FToggleCell — simple toggle row
@interface WToggleRow : UIView
@property (nonatomic, strong) UISwitch *sw;
@property (nonatomic, copy) void (^onToggle)(BOOL);
@end
@implementation WToggleRow
- (instancetype)initWithLabel:(NSString *)label accent:(UIColor *)accent on:(BOOL)on action:(void(^)(BOOL))action {
    self = [super init];
    if (self) {
        _onToggle = action;
        self.backgroundColor = W_BTN;
        self.layer.cornerRadius = 12;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = (accent ?: W_SUN).CGColor;
        self.layer.shadowColor = (accent ?: W_SUN).CGColor;
        self.layer.shadowOpacity = 0.35; self.layer.shadowRadius = 5;

        UILabel *lbl = [[UILabel alloc] init];
        lbl.text = label; lbl.textColor = W_TEXT;
        lbl.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13] ?: [UIFont boldSystemFontOfSize:13];
        lbl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:lbl];

        _sw = [[UISwitch alloc] init];
        _sw.on = on;
        _sw.onTintColor = accent ?: W_SUN;
        _sw.translatesAutoresizingMaskIntoConstraints = NO;
        [_sw addTarget:self action:@selector(toggled:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_sw];

        [NSLayoutConstraint activateConstraints:@[
            [lbl.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
            [lbl.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [_sw.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
            [_sw.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        ]];
    }
    return self;
}
- (void)toggled:(UISwitch *)sw { if (_onToggle) _onToggle(sw.on); }
@end

// ═══════════════════════════════════════════════════════
// QUANTITY POPUP
// ═══════════════════════════════════════════════════════

@interface WQtyPopup : UIView
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic) NSInteger qty;
@end
@implementation WQtyPopup
- (instancetype)initWithFrame:(CGRect)frame item:(NSString *)item {
    self = [super initWithFrame:frame];
    if (self) {
        _itemName = item; _qty = 1;
        self.backgroundColor = [UIColor colorWithRed:0.07 green:0.05 blue:0.14 alpha:0.98];
        self.layer.cornerRadius = 18;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = W_SUN.CGColor;
        self.layer.shadowColor = W_SUN.CGColor;
        self.layer.shadowOpacity = 0.8; self.layer.shadowRadius = 22;
        [self build];
    }
    return self;
}
- (void)build {
    CGFloat w = self.bounds.size.width;

    // Location badge
    UILabel *loc = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, w-20, 14)];
    loc.text = [NSString stringWithFormat:@"📍 %@  (%.1f, %.1f, %.1f)", g_locName, g_x, g_y, g_z];
    loc.textColor = W_MINT; loc.font = [UIFont fontWithName:@"AvenirNext-Medium" size:9] ?: [UIFont systemFontOfSize:9];
    loc.textAlignment = NSTextAlignmentCenter; [self addSubview:loc];

    // Flower decoration
    UILabel *deco = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, w, 20)];
    deco.text = @"🌸 ✨ 🌟 ✨ 🌸";
    deco.textAlignment = NSTextAlignmentCenter;
    deco.font = [UIFont systemFontOfSize:12]; [self addSubview:deco];

    // Item name
    NSString *display = [[_itemName stringByReplacingOccurrencesOfString:@"item_" withString:@""]
                          stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 48, w-20, 22)];
    name.text = display; name.textColor = W_SUN;
    name.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:15] ?: [UIFont boldSystemFontOfSize:15];
    name.textAlignment = NSTextAlignmentCenter;
    name.layer.shadowColor = W_SUN.CGColor; name.layer.shadowOpacity = 0.9; name.layer.shadowRadius = 8;
    [self addSubview:name];

    // Qty display
    UILabel *ql = [[UILabel alloc] initWithFrame:CGRectMake(0, 74, w, 36)];
    ql.tag = 999; ql.text = @"x1"; ql.textColor = [UIColor whiteColor];
    ql.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:30] ?: [UIFont boldSystemFontOfSize:30];
    ql.textAlignment = NSTextAlignmentCenter;
    ql.layer.shadowColor = W_ORANGE.CGColor; ql.layer.shadowOpacity = 0.9; ql.layer.shadowRadius = 10;
    [self addSubview:ql];

    // Qty buttons
    NSArray *qtys = @[@1, @5, @10, @50, @100];
    CGFloat bw = (w-20) / qtys.count;
    for (int i = 0; i < (int)qtys.count; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(10 + i*bw, 116, bw-4, 28);
        [b setTitle:[NSString stringWithFormat:@"x%@", qtys[i]] forState:UIControlStateNormal];
        [b setTitleColor:W_SKY forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:12] ?: [UIFont boldSystemFontOfSize:12];
        b.backgroundColor = [UIColor colorWithRed:0.15 green:0.1 blue:0.28 alpha:1.0];
        b.layer.cornerRadius = 8;
        b.layer.borderWidth = 0.8; b.layer.borderColor = W_SKY.CGColor;
        b.tag = [qtys[i] integerValue];
        [b addTarget:self action:@selector(setQty:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b];
    }

    // Spawn button
    UIButton *spawn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawn.frame = CGRectMake(14, 152, w-28, 42);
    [spawn setTitle:@"🌸  SPAWN HERE  🌸" forState:UIControlStateNormal];
    [spawn setTitleColor:[UIColor colorWithRed:0.05 green:0.03 blue:0.1 alpha:1.0] forState:UIControlStateNormal];
    spawn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:15] ?: [UIFont boldSystemFontOfSize:15];
    CAGradientLayer *sg = [CAGradientLayer layer]; sg.frame = CGRectMake(0,0,w-28,42);
    sg.colors = @[(id)W_SUN.CGColor, (id)W_ORANGE.CGColor];
    sg.startPoint = CGPointMake(0,0.5); sg.endPoint = CGPointMake(1,0.5);
    sg.cornerRadius = 12;
    [spawn.layer insertSublayer:sg atIndex:0];
    spawn.layer.cornerRadius = 12;
    spawn.layer.shadowColor = W_ORANGE.CGColor; spawn.layer.shadowOpacity = 0.9; spawn.layer.shadowRadius = 12;
    [spawn addTarget:self action:@selector(doSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:spawn];

    // Cancel
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.frame = CGRectMake(14, 200, w-28, 28);
    [cancel setTitle:@"✕  Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:W_PINK forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12] ?: [UIFont systemFontOfSize:12];
    [cancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancel];
}
- (void)setQty:(UIButton *)s {
    self.qty = s.tag;
    ((UILabel *)[self viewWithTag:999]).text = [NSString stringWithFormat:@"x%ld", (long)self.qty];
}
- (void)doSpawn {
    wSpawnItem(self.itemName, self.qty);
    UILabel *flash = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, self.bounds.size.width, 28)];
    flash.text = [NSString stringWithFormat:@"🌸 Spawned at %@ 🌸", g_locName];
    flash.textAlignment = NSTextAlignmentCenter; flash.textColor = W_MINT;
    flash.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:12] ?: [UIFont boldSystemFontOfSize:12];
    flash.layer.shadowColor = W_MINT.CGColor; flash.layer.shadowOpacity = 1.0; flash.layer.shadowRadius = 10;
    [self addSubview:flash];
    [UIView animateWithDuration:0.3 animations:^{ flash.alpha = 1.0; } completion:^(BOOL d) {
        [UIView animateWithDuration:0.5 delay:0.8 options:0 animations:^{ flash.alpha = 0; }
            completion:^(BOOL dd) { [flash removeFromSuperview]; [self dismiss]; }];
    }];
}
- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0; self.transform = CGAffineTransformMakeScale(0.88, 0.88);
    } completion:^(BOOL d) { [self removeFromSuperview]; }];
}
@end

// ═══════════════════════════════════════════════════════
// BASE SCROLL TAB
// ═══════════════════════════════════════════════════════

@interface WScrollTab : UIView
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *content;
@property (nonatomic) CGFloat yOff;
- (void)setup;
- (void)addSection:(NSString *)title;
- (void)addButton:(NSString *)title accent:(UIColor *)accent cmd:(NSString *)cmd;
- (void)addToggle:(NSString *)title accent:(UIColor *)accent on:(BOOL)on action:(void(^)(BOOL))action;
- (void)addView:(UIView *)v height:(CGFloat)h;
- (void)finalize;
@end

@implementation WScrollTab
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    _scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.backgroundColor = [UIColor clearColor];
    [self addSubview:_scroll];
    _content = [[UIView alloc] init];
    _content.backgroundColor = [UIColor clearColor];
    [_scroll addSubview:_content];
    _yOff = 8;
}
- (void)addSection:(NSString *)title {
    _yOff += 8;
    [_content addSubview:wSectionHeader(title, _yOff, self.bounds.size.width)]; _yOff += 20;
    [_content addSubview:wDivider(_yOff, self.bounds.size.width)]; _yOff += 8;
}
- (void)addView:(UIView *)v height:(CGFloat)h {
    v.frame = CGRectMake(10, _yOff, self.bounds.size.width - 20, h);
    [_content addSubview:v]; _yOff += h + 7;
}
- (void)addButton:(NSString *)title accent:(UIColor *)accent cmd:(NSString *)cmd {
    UIButton *b = wBtn(title, accent);
    b.frame = CGRectMake(10, _yOff, self.bounds.size.width - 20, 42);
    objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_content addSubview:b]; _yOff += 49;
}
- (void)addToggle:(NSString *)title accent:(UIColor *)accent on:(BOOL)on action:(void(^)(BOOL))action {
    WToggleRow *t = [[WToggleRow alloc] initWithLabel:title accent:accent on:on action:action];
    [self addView:t height:44];
}
- (void)btnTapped:(UIButton *)sender {
    NSString *cmd = objc_getAssociatedObject(sender, "cmd");
    if (cmd) sendCmd(cmd);
    [UIView animateWithDuration:0.08 animations:^{ sender.transform = CGAffineTransformMakeScale(0.95,0.95); }
        completion:^(BOOL d){ [UIView animateWithDuration:0.12 animations:^{ sender.transform = CGAffineTransformIdentity; }]; }];
}
- (void)finalize {
    _content.frame = CGRectMake(0, 0, self.bounds.size.width, _yOff + 12);
    _scroll.contentSize = _content.frame.size;
}
@end

// ═══════════════════════════════════════════════════════
// TAB 1: PLAYER MODS
// ═══════════════════════════════════════════════════════

@interface WPlayerModsTab : WScrollTab @end
@implementation WPlayerModsTab
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self addSection:@"🛡️  PROTECTION"];
        [self addToggle:@"🛡️  Invincibility" accent:W_MINT on:NO action:^(BOOL on){ sendCmd(on ? @"hey ai god on" : @"hey ai god off"); }];
        [self addToggle:@"👻  Ghost Mode" accent:W_SKY on:NO action:^(BOOL on){ sendCmd(on ? @"hey ai invisible on" : @"hey ai invisible off"); }];

        [self addSection:@"⚡  MOVEMENT"];
        [self addButton:@"💨  Fart Boost" accent:W_MINT cmd:@"hey ai fart boost"];
        [self addButton:@"🦨  Stink Jump" accent:W_ORANGE cmd:@"hey ai stink jump"];
        [self addButton:@"🌕  Moon Teleport" accent:W_SKY cmd:@"hey ai tp moon"];
        [self addButton:@"🫧  Jellify Yourself" accent:W_PURPLE cmd:@"hey ai jellify self"];

        [self addSection:@"💰  MONEY"];
        [self addButton:@"♾️  Infinite Wallet (99M)" accent:W_SUN cmd:@"hey ai money 99999999"];
        [self addButton:@"💰  Give 9,999,999 Coins" accent:W_SUN cmd:@"hey ai money 9999999"];
        [self addButton:@"🪙  Give 1,000 Coins" accent:W_ORANGE cmd:@"hey ai money 1000"];

        [self addSection:@"⚡  BUFFS"];
        for (NSString *buff in @[@"Speedboost", @"Bloodlust", @"Bounce", @"Grow", @"Shrink", @"Fling", @"Kick", @"Love", @"Illness"]) {
            NSString *b = buff;
            [self addButton:[NSString stringWithFormat:@"⚡  %@", buff] accent:W_PURPLE
                       cmd:[NSString stringWithFormat:@"hey ai buff %@", b]];
        }
        [self addButton:@"✨  Apply ALL Buffs" accent:W_PINK cmd:@"hey ai buff all"];

        [self addSection:@"🎨  APPEARANCE"];
        [self addToggle:@"🌈  Rainbow Self" accent:W_PINK on:NO action:^(BOOL on){ sendCmd(on ? @"hey ai rainbow self on" : @"hey ai rainbow self off"); }];
        [self addButton:@"🗿  Big Head Mode" accent:W_ORANGE cmd:@"hey ai bighead self"];

        [self finalize];
    }
    return self;
}
@end

// ═══════════════════════════════════════════════════════
// TAB 2: TROLLING
// ═══════════════════════════════════════════════════════

@interface WTrollingTab : WScrollTab @end
@implementation WTrollingTab
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self addSection:@"🎭  VISUAL CHAOS"];
        [self addToggle:@"🌈  Disco Players" accent:W_PINK on:NO action:^(BOOL on){ sendCmd(on ? @"hey ai rainbow players on" : @"hey ai rainbow players off"); }];
        [self addToggle:@"🌈  Disco Monsters" accent:W_PURPLE on:NO action:^(BOOL on){ sendCmd(on ? @"hey ai rainbow monsters on" : @"hey ai rainbow monsters off"); }];
        [self addButton:@"🗿  Big Head Everyone" accent:W_ORANGE cmd:@"hey ai bighead all"];
        [self addButton:@"🩷  Pink Haze (All Screens)" accent:W_PINK cmd:@"hey ai screen pink"];
        [self addButton:@"🩸  Blood Screen (All)" accent:[UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0] cmd:@"hey ai screen red"];

        [self addSection:@"🔊  VOICE & SOUND"];
        [self addButton:@"🔇  Muffle All Voices" accent:W_SKY cmd:@"hey ai voice muffle"];
        [self addButton:@"🐭  Squeaky Voices" accent:W_MINT cmd:@"hey ai voice squeak"];
        [self addButton:@"📳  Shake All Screens" accent:W_ORANGE cmd:@"hey ai shake"];
        [self addButton:@"💥  Mega Earthquake" accent:W_PINK cmd:@"hey ai shake insane"];

        [self addSection:@"☠️  DAMAGE & CHAOS"];
        [self addButton:@"💀  Wipe Lobby (Kill All)" accent:[UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0] cmd:@"hey ai kill all players"];
        [self addButton:@"👾  Annihilate Monsters" accent:W_PURPLE cmd:@"hey ai kill all monsters"];
        [self addButton:@"🧊  Freeze Everyone" accent:W_SKY cmd:@"hey ai stun all"];
        [self addButton:@"🦨  Stink Bomb (All)" accent:W_MINT cmd:@"hey ai stink all"];
        [self addButton:@"🚀  Hyper Launch Everyone" accent:W_ORANGE cmd:@"hey ai launch all"];
        [self addButton:@"🌀  Fling All Players" accent:W_PURPLE cmd:@"hey ai fling all"];
        [self addButton:@"🕳️  Void Drop (Death Zone)" accent:[UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:1.0] cmd:@"hey ai tp all death"];
        [self addButton:@"🧲  Recall All to Me" accent:W_SKY cmd:@"hey ai teleport all to me"];
        [self addButton:@"⚡  Speed Rush All" accent:W_SUN cmd:@"hey ai speed all"];

        [self finalize];
    }
    return self;
}
@end

// ═══════════════════════════════════════════════════════
// TAB 3: EXPLOITS
// ═══════════════════════════════════════════════════════

@interface WExploitsTab : WScrollTab @end
@implementation WExploitsTab
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self addSection:@"🌌  ITEM EXPLOITS"];
        [self addButton:@"⚫  Void Stash (Heavy Stick)" accent:W_PURPLE cmd:@"hey ai spawn heavystick"];
        [self addButton:@"🪨  Ultra Heavy Stick Pack" accent:W_ORANGE cmd:@"hey ai spawn heavystick backpack"];
        [self addButton:@"🌈  Rainbow Quiver Stick" accent:W_PINK cmd:@"hey ai spawn colorstick quiver"];
        [self addButton:@"🌀  Portal Grenade Backpack" accent:W_SKY cmd:@"hey ai spawn telegrenade backpack"];
        [self addButton:@"🛸  No Gravity (All Items)" accent:W_MINT cmd:@"hey ai no gravity items"];
        [self addButton:@"🤖  Spawn Robo Army" accent:W_SKY cmd:@"hey ai spawn robomonke"];
        [self addButton:@"⬆️  Bounce Backpack Trap" accent:W_MINT cmd:@"hey ai spawn bounce backpack"];
        [self addButton:@"🗑️  Delete All World Items" accent:[UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0] cmd:@"hey ai delete all items"];

        [self addSection:@"💸  MONEY EXPLOITS"];
        [self addButton:@"🎰  Explode Money Machine" accent:W_SUN cmd:@"hey ai explode money machine"];
        [self addButton:@"🌧️  Ammo Rain (All)" accent:W_ORANGE cmd:@"hey ai spawn ammo giveaway"];
        [self addButton:@"🔩  Nut Drop (All)" accent:W_SUBTEXT cmd:@"hey ai spawn nut giveaway"];
        [self addButton:@"🎁  Gift Car Drop" accent:W_PINK cmd:@"hey ai spawn gift car"];

        [self addSection:@"🏗️  WORLD OBJECTS"];
        for (NSString *prefab in @[@"🌌  Duplicator", @"🚗  Vehicle_Buggy", @"😈  HellAltar",
                                   @"🎰  ClawMachineNetObject", @"🎬  MovieTheater",
                                   @"🏮  LootLantern", @"🔮  FortuneTellerNet",
                                   @"🥚  ExplosiveEgg", @"🎈  InflatedBalloon"]) {
            NSString *name = [[prefab componentsSeparatedByString:@"  "] lastObject];
            NSString *cmd = [NSString stringWithFormat:@"hey ai spawn prefab %@ %.2f %.2f %.2f", name, g_x, g_y, g_z];
            [self addButton:prefab accent:W_SKY cmd:cmd];
        }

        [self finalize];
    }
    return self;
}
@end

// ═══════════════════════════════════════════════════════
// TAB 4: SPAWNING
// ═══════════════════════════════════════════════════════

@interface WSpawningTab : UIView <UISearchBarDelegate>
@property (nonatomic, strong) NSArray *allItems, *filtered;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIScrollView *itemScroll;
@property (nonatomic, strong) UIView *itemContent;
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) UIScrollView *mobScroll;
@property (nonatomic, weak) UIView *rootView;
@end

@implementation WSpawningTab

- (instancetype)initWithFrame:(CGRect)frame rootView:(UIView *)root {
    self = [super initWithFrame:frame];
    if (self) {
        _rootView = root;
        self.backgroundColor = [UIColor clearColor];
        [self buildItems];
        [self buildUI];
    }
    return self;
}

- (void)buildItems {
    _allItems = @[
        @"item_apple",@"item_banana",@"item_banana_chips",@"item_large_banana",
        @"item_pineapple",@"item_beans",@"item_burrito",@"item_cracker",
        @"item_popcorn",@"item_turkey_leg",@"item_turkey_whole",@"item_pumpkin_pie",
        @"item_stinky_cheese",@"item_hot_cocoa",@"item_cola",@"item_cola_large",
        @"item_ac_cola",@"item_company_ration",@"item_company_ration_heal",@"item_zombie_meat",
        @"item_pistol_dragon",@"item_revolver",@"item_revolver_gold",
        @"item_shotgun",@"item_shotgun_viper",@"item_crossbow",@"item_crossbow_heart",
        @"item_rpg",@"item_rpg_cny",@"item_rpg_easter",@"item_rpg_smshr",@"item_rpg_spear",
        @"item_flamethrower",@"item_flamethrower_skull",@"item_flamethrower_skull_ruby",
        @"item_grenade_launcher",@"item_heart_gun",@"item_radiation_gun",
        @"item_moneygun",@"item_friend_launcher",@"item_flaregun",
        @"item_arena_pistol",@"item_arena_shotgun",
        @"item_axe",@"item_hatchet",@"item_baseball_bat",@"item_crowbar",
        @"item_demon_sword",@"item_alphablade",@"item_great_sword",@"item_lance",
        @"item_police_baton",@"item_frying_pan",@"item_shovel",@"item_broom",
        @"item_broom_halloween",@"item_viking_hammer",@"item_viking_hammer_twilight",
        @"item_pinata_bat",@"item_hookshot_sword",@"item_stellarsword_blue",@"item_stellarsword_gold",
        @"item_treestick",@"item_stick_bone",@"item_stick_armbones",
        @"item_boomerang",@"item_guided_boomerang",
        @"item_grenade",@"item_grenade_gold",@"item_dynamite",@"item_dynamite_cube",
        @"item_sticky_dynamite",@"item_timebomb",@"item_landmine",@"item_flashbang",
        @"item_cluster_grenade",@"item_confetti_grenade",@"item_broccoli_grenade",
        @"item_broccoli_shrink_grenade",@"item_pumpkin_bomb",@"item_impulse_grenade",
        @"item_tele_grenade",@"item_anti_gravity_grenade",@"item_stash_grenade",
        @"item_tripwire_explosive",@"item_arrow_bomb",
        @"item_backpack",@"item_backpack_big",@"item_backpack_black",@"item_backpack_cube",
        @"item_backpack_gold",@"item_backpack_green",@"item_backpack_mega",@"item_backpack_neon",
        @"item_backpack_pink",@"item_backpack_realistic",@"item_backpack_skull",@"item_backpack_white",
        @"item_backpack_with_flashlight",@"item_backpack_large_base",
        @"item_backpack_large_basketball",@"item_backpack_large_clover",@"item_backpack_small_base",
        @"item_goldbar",@"item_goldcoin",@"item_ruby",@"item_rare_card",
        @"item_diamond_jade_koi",@"item_trophy",@"item_ceo_plaque",@"item_token_circus",@"item_d20",
        @"item_flashlight",@"item_flashlight_mega",@"item_flashlight_red",
        @"item_scanner",@"item_prop_scanner",@"item_hookshot",@"item_teleport_gun",
        @"item_portable_teleporter",@"item_hoverpad",@"item_jetpack",@"item_pogostick",
        @"item_zipline_gun",@"item_drill",@"item_drill_neon",@"item_pickaxe",@"item_pickaxe_cny",
        @"item_pickaxe_cube",@"item_pickaxe_realistic",@"item_rope",@"item_saddle",
        @"item_shredder",@"item_remote_controller",@"item_server_pad",@"item_keycard",
        @"item_hh_key",@"item_mountain_key",@"item_disposable_camera",@"item_tablet",
        @"item_calculator",@"item_electrical_tape",@"item_tapedispenser",@"item_stapler",
        @"item_scissors",@"item_eraser",@"item_harddrive",@"item_floppy3",@"item_floppy5",
        @"item_joystick",@"item_joystick_inv_y",@"item_gameboy",@"item_megaphone",
        @"item_shield",@"item_shield_bones",@"item_shield_police",
        @"item_shield_viking_1",@"item_shield_viking_2",@"item_shield_viking_3",@"item_shield_viking_4",
        @"item_ogre_hands",@"item_bloodlust_vial",
        @"item_snowball",@"item_snowboard",@"item_snowboard_2",@"item_snowboard_3",
        @"item_snowboard_4",@"item_snowboard_auto",@"item_skipole",@"item_skishoe",
        @"item_skishoe_2",@"item_skishoe_3",@"item_skishoe_4",@"item_football",
        @"item_finger_board",@"item_trampoline",
        @"item_basic_fishing_rod",@"item_carp",@"item_crappie",
        @"item_goopfish",@"item_rotten_fish",@"item_fish_dumb_fish",
        @"item_boombox",@"item_boombox_neon",@"item_ukulele",@"item_ukulele_gold",
        @"item_hawaiian_drum",@"item_theremin",@"item_disc",@"item_balloon",
        @"item_balloon_heart",@"item_whoopie",@"item_rubberducky",@"item_glowstick",
        @"item_sticker_dispenser",@"item_kissy",
        @"item_crate",@"item_cardboard_box",@"item_plank",@"item_brick",
        @"item_metal_rod",@"item_metal_plate",@"item_metal_ball",@"item_metal_triangle",
        @"item_steel_beam",@"item_truss",@"item_wood_log",@"item_wood_pallet",
        @"item_pelican_case",@"item_paperpack",@"item_box_fan",@"item_motor",@"item_piston",
        @"item_nut",@"item_wheelhandle",@"item_wheelhandle_big",
        @"item_painting_canvas",@"item_clapper",@"item_film_reel",
        @"item_ore_copper_s",@"item_ore_copper_m",@"item_ore_copper_l",
        @"item_ore_silver_s",@"item_ore_silver_m",@"item_ore_silver_l",
        @"item_ore_gold_s",@"item_ore_gold_m",@"item_ore_gold_l",@"item_ore_hell",
        @"item_uranium_chunk_s",@"item_uranium_chunk_m",@"item_uranium_chunk_l",
        @"item_goop",@"item_sludge",@"item_radioactive_broccoli",@"item_shrinking_broccoli",
        @"item_brain_chunk",@"item_heart_chunk",@"item_bighead_larva",
        @"item_snail_friend",@"item_robo_monke",@"item_robot_arm_left",
        @"item_robot_arm_right",@"item_robot_head",@"item_cutie_dead",
        @"item_bottled_message",@"item_momboss_box",
        @"item_quest_gy_skull",@"item_quest_gy_skull_special",
        @"item_quest_hlal_brain",@"item_quest_hlal_eyeball",
        @"item_quest_hlal_flesh",@"item_quest_hlal_heart",@"item_quest_key_graveyard",
        @"item_quest_vhs",@"item_quest_vhs_backlots",@"item_quest_vhs_basement",
        @"item_quest_vhs_cave",@"item_quest_vhs_circus_day",@"item_quest_vhs_forest",
        @"item_quest_vhs_graveyard",@"item_quest_vhs_haunted_house",@"item_quest_vhs_hell",
        @"item_quest_vhs_lab",@"item_quest_vhs_lake",@"item_quest_vhs_lobby",
        @"item_quest_vhs_mines",@"item_quest_vhs_mountain",@"item_quest_vhs_office",
        @"item_quest_vhs_sewers",
        @"item_revolver_ammo",@"item_shotgun_ammo",@"item_rpg_ammo",
        @"item_arrow",@"item_arrow_heart",@"item_arrow_lightbulb",@"item_arrow_teleport",
        @"item_quiver",@"item_quiver_heart",
        @"item_randombox_base",@"item_randombox_mobloot_big",@"item_randombox_mobloot_medium",
        @"item_randombox_mobloot_small",@"item_randombox_mobloot_weapons",@"item_randombox_mobloot_zombie",
        @"item_umbrella",@"item_umbrella_clover",@"item_umbrella_squirrel",
        @"item_toilet_paper",@"item_toilet_paper_mega",@"item_boot",@"item_egg",@"item_coconut_shell",
        @"item_pumpkinjack",@"item_pumpkinjack_small",@"item_rpg_easter",@"item_pickaxe_cny",@"item_rpg_cny",
    ];
    _filtered = _allItems;
}

- (void)buildUI {
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;

    // Segment
    _seg = [[UISegmentedControl alloc] initWithItems:@[@"📦  Items", @"🧟  Mobs"]];
    _seg.frame = CGRectMake(10, 6, w-20, 32);
    _seg.selectedSegmentIndex = 0;
    if (@available(iOS 13.0, *)) {
        _seg.selectedSegmentTintColor = W_SUN;
        [_seg setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.05 green:0.03 blue:0.1 alpha:1.0]} forState:UIControlStateSelected];
        [_seg setTitleTextAttributes:@{NSForegroundColorAttributeName:W_TEXT} forState:UIControlStateNormal];
    }
    [_seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_seg];

    // Search
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 44, w-20, 34)];
    _searchBar.placeholder = @"🌸 Search items...";
    _searchBar.barStyle = UIBarStyleBlack;
    _searchBar.translucent = YES;
    _searchBar.delegate = self;
    _searchBar.layer.cornerRadius = 8;
    _searchBar.clipsToBounds = YES;
    [self addSubview:_searchBar];

    // Item scroll
    _itemScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,84,w,h-84)];
    _itemScroll.showsVerticalScrollIndicator = NO;
    _itemScroll.backgroundColor = [UIColor clearColor];
    [self addSubview:_itemScroll];
    _itemContent = [[UIView alloc] init];
    _itemContent.backgroundColor = [UIColor clearColor];
    [_itemScroll addSubview:_itemContent];
    [self rebuildItems];

    // Mob scroll
    _mobScroll = [self buildMobScroll:CGRectMake(0,44,w,h-44)];
    _mobScroll.hidden = YES;
    [self addSubview:_mobScroll];
}

- (UIScrollView *)buildMobScroll:(CGRect)frame {
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:frame];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.backgroundColor = [UIColor clearColor];
    UIView *content = [[UIView alloc] init];
    CGFloat w = frame.size.width, y = 8;

    // Section header
    [content addSubview:wSectionHeader(@"🧟  MONSTERS", y, w)]; y += 20;
    [content addSubview:wDivider(y, w)]; y += 8;

    NSArray *mobs = @[
        @"👁️  Angler",@"😡  AnglerMad",@"💪  Armstrong",@"😡  ArmstrongMad",
        @"👻  Banshee",@"🗿  BigHead",@"🫧  Blob",@"💣  Bomb",@"💥  Bomber",
        @"💥  BomberFlashbang",@"😡  BomberMad",@"🐔  Chicken",@"🥰  Cutie",
        @"🦠  Cyst",@"👁️  EvilEye",@"👁️  EvilEyePinata",@"👁️  EvilEyePinataLarge",
        @"🦍  FakeGorilla",@"🪲  FlyingSwarm",@"🌲  ForestMob",@"👹  Giant",
        @"💀  Giant_GraveyardBoss",@"🧟  HordeMob",@"🦒  Lanky",@"🪞  Mimic",
        @"🤖  NextBot",@"🤖  NextBotStatic",@"👻  Phantom",@"🫀  PolypMass",
        @"🎭  Puppet",@"🔴  RedGreen",@"😡  RedGreenMad",@"🎪  Ringmaster",
        @"🤖  RoboMonke",@"🐕  RobotDog",@"🛴  Segway",@"👤  Shadow",
        @"🕷️  SpiderCave",@"🕷️  Spider",@"⚡  Thunder",@"🐛  TubeMonster",
    ];

    for (NSString *full in mobs) {
        NSString *mobName = [[full componentsSeparatedByString:@"  "] lastObject];
        UIButton *b = wBtn(full, W_PURPLE);
        b.frame = CGRectMake(10, y, w-20, 42);
        objc_setAssociatedObject(b, "mob", mobName, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [b addTarget:self action:@selector(mobTapped:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:b]; y += 49;
    }

    content.frame = CGRectMake(0, 0, w, y+10);
    scroll.contentSize = content.frame.size;
    [scroll addSubview:content];
    return scroll;
}

- (void)mobTapped:(UIButton *)s {
    NSString *mob = objc_getAssociatedObject(s, "mob");
    if (mob) wSpawnMob(mob);
    [UIView animateWithDuration:0.08 animations:^{ s.transform=CGAffineTransformMakeScale(0.95,0.95); }
        completion:^(BOOL d){ [UIView animateWithDuration:0.12 animations:^{ s.transform=CGAffineTransformIdentity; }]; }];
}

- (NSString *)emojiFor:(NSString *)item {
    if ([item containsString:@"apple"]||[item containsString:@"banana"]||[item containsString:@"cola"]||
        [item containsString:@"turkey"]||[item containsString:@"popcorn"]||[item containsString:@"burrito"]||
        [item containsString:@"ration"]||[item containsString:@"cocoa"]||[item containsString:@"pineapple"]||
        [item containsString:@"cheese"]||[item containsString:@"pie"]||[item containsString:@"meat"])
        return @"🍎";
    if ([item containsString:@"rpg"]||[item containsString:@"shotgun"]||[item containsString:@"pistol"]||
        [item containsString:@"revolver"]||[item containsString:@"flamethrower"]||[item containsString:@"crossbow"]||
        [item containsString:@"radiation"]||[item containsString:@"moneygun"]||[item containsString:@"flaregun"]||
        [item containsString:@"launcher"]) return @"🔫";
    if ([item containsString:@"grenade"]||[item containsString:@"dynamite"]||[item containsString:@"bomb"]||
        [item containsString:@"landmine"]||[item containsString:@"timebomb"]||[item containsString:@"flashbang"]||
        [item containsString:@"tripwire"]||[item containsString:@"cluster"]||[item containsString:@"impulse"])
        return @"💣";
    if ([item containsString:@"sword"]||[item containsString:@"axe"]||[item containsString:@"bat"]||
        [item containsString:@"crowbar"]||[item containsString:@"lance"]||[item containsString:@"broom"]||
        [item containsString:@"hammer"]||[item containsString:@"boomerang"]||[item containsString:@"shovel"]||
        [item containsString:@"hatchet"]||[item containsString:@"frying"]||[item containsString:@"baton"])
        return @"⚔️";
    if ([item containsString:@"goldbar"]||[item containsString:@"goldcoin"]||[item containsString:@"ruby"]||
        [item containsString:@"rare_card"]||[item containsString:@"trophy"]||[item containsString:@"diamond"])
        return @"💰";
    if ([item containsString:@"backpack"]) return @"🎒";
    if ([item containsString:@"ore"]||[item containsString:@"uranium"]||[item containsString:@"broccoli"]) return @"🪨";
    if ([item containsString:@"vhs"]||[item containsString:@"quest"]) return @"📼";
    if ([item containsString:@"flashlight"]||[item containsString:@"jetpack"]||[item containsString:@"hookshot"]||
        [item containsString:@"teleport"]||[item containsString:@"scanner"]||[item containsString:@"drill"]||
        [item containsString:@"pickaxe"]||[item containsString:@"hoverpad"]||[item containsString:@"zipline"]||
        [item containsString:@"key"]) return @"🔦";
    if ([item containsString:@"snowboard"]||[item containsString:@"snowball"]||[item containsString:@"ski"]||
        [item containsString:@"football"]||[item containsString:@"trampoline"]) return @"⛷️";
    if ([item containsString:@"boombox"]||[item containsString:@"ukulele"]||[item containsString:@"drum"]||
        [item containsString:@"theremin"]||[item containsString:@"balloon"]||[item containsString:@"disc"]||
        [item containsString:@"glowstick"]||[item containsString:@"rubberducky"]) return @"🎵";
    if ([item containsString:@"fish"]||[item containsString:@"rod"]||[item containsString:@"carp"]) return @"🎣";
    if ([item containsString:@"shield"]||[item containsString:@"ogre"]||[item containsString:@"bloodlust"]) return @"🛡️";
    if ([item containsString:@"xmas"]||[item containsString:@"easter"]||[item containsString:@"pumpkin"]||
        [item containsString:@"cny"]||[item containsString:@"clover"]) return @"🎄";
    if ([item containsString:@"ammo"]||[item containsString:@"arrow"]||[item containsString:@"quiver"]) return @"🏹";
    return @"📦";
}

- (void)rebuildItems {
    for (UIView *v in _itemContent.subviews) [v removeFromSuperview];
    CGFloat w = self.bounds.size.width, pad = 10, btnH = 42, y = 6;

    // Accent colors cycle
    NSArray *accents = @[W_SUN, W_ORANGE, W_PINK, W_MINT, W_SKY, W_PURPLE];
    int ai = 0;

    for (NSString *item in _filtered) {
        UIButton *btn = wBtn([NSString stringWithFormat:@"%@  %@",
                              [self emojiFor:item],
                              [[item stringByReplacingOccurrencesOfString:@"item_" withString:@""]
                               stringByReplacingOccurrencesOfString:@"_" withString:@" "]],
                             accents[ai % accents.count]);
        btn.frame = CGRectMake(pad, y, w-pad*2, btnH);
        btn.accessibilityLabel = item;
        [btn addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_itemContent addSubview:btn];
        y += btnH + 7; ai++;
    }
    _itemContent.frame = CGRectMake(0,0,w,y+10);
    _itemScroll.contentSize = _itemContent.frame.size;
}

- (void)itemTapped:(UIButton *)sender {
    UIView *root = self.rootView ?: self;
    WQtyPopup *popup = [[WQtyPopup alloc]
        initWithFrame:CGRectMake(root.bounds.size.width/2-150, root.bounds.size.height/2-125, 300, 240)
                 item:sender.accessibilityLabel];
    popup.alpha = 0; popup.transform = CGAffineTransformMakeScale(0.82,0.82);
    [root addSubview:popup];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.68 initialSpringVelocity:0.5 options:0 animations:^{
        popup.alpha = 1; popup.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)segChanged:(UISegmentedControl *)seg {
    BOOL items = seg.selectedSegmentIndex == 0;
    _searchBar.hidden = !items; _itemScroll.hidden = !items; _mobScroll.hidden = items;
}
- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)text {
    _filtered = text.length == 0 ? _allItems :
        [_allItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text]];
    [self rebuildItems];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)sb { [sb resignFirstResponder]; }

@end

// ═══════════════════════════════════════════════════════
// TAB 5: SETTINGS (Locations)
// ═══════════════════════════════════════════════════════

@interface WSettingsTab : UIView
@property (nonatomic, strong) UILabel *badge;
@end

@implementation WSettingsTab
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self build];
    }
    return self;
}
- (void)build {
    CGFloat w = self.bounds.size.width;
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.backgroundColor = [UIColor clearColor];
    [self addSubview:scroll];
    UIView *content = [[UIView alloc] init];
    CGFloat y = 8;

    // Active badge
    _badge = [[UILabel alloc] initWithFrame:CGRectMake(10, y, w-20, 40)];
    _badge.text = [NSString stringWithFormat:@"📍  %@  (%.2f, %.2f, %.2f)", g_locName, g_x, g_y, g_z];
    _badge.textColor = W_DARK;
    _badge.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11] ?: [UIFont boldSystemFontOfSize:11];
    _badge.textAlignment = NSTextAlignmentCenter;
    _badge.numberOfLines = 1; _badge.adjustsFontSizeToFitWidth = YES;
    _badge.clipsToBounds = YES; _badge.layer.cornerRadius = 10;

    // Gradient badge bg
    CAGradientLayer *badgeGrad = [CAGradientLayer layer];
    badgeGrad.frame = CGRectMake(0,0,w-20,40);
    badgeGrad.colors = @[(id)W_SUN.CGColor, (id)W_ORANGE.CGColor];
    badgeGrad.startPoint = CGPointMake(0,0.5); badgeGrad.endPoint = CGPointMake(1,0.5);
    badgeGrad.cornerRadius = 10;
    [_badge.layer insertSublayer:badgeGrad atIndex:0];
    [content addSubview:_badge]; y += 50;

    [content addSubview:wSectionHeader(@"📍  CHOOSE SPAWN LOCATION", y, w)]; y += 20;
    [content addSubview:wDivider(y, w)]; y += 10;

    // Decorative label
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(10, y, w-20, 16)];
    hint.text = @"🌸  Tap a location to set it as your active spawn point  🌸";
    hint.textColor = W_SUBTEXT;
    hint.font = [UIFont fontWithName:@"AvenirNext-Medium" size:9] ?: [UIFont systemFontOfSize:9];
    hint.textAlignment = NSTextAlignmentCenter;
    [content addSubview:hint]; y += 22;

    NSArray *locs = @[
        @{@"n":@"Sell",          @"e":@"💸", @"x":@(-14.50), @"y":@(4.00),   @"z":@(-23.50)},
        @{@"n":@"Stage 5",       @"e":@"🎭", @"x":@(-5.00),  @"y":@(3.00),   @"z":@(-160.00)},
        @{@"n":@"Toilet",        @"e":@"🚽", @"x":@(-6.00),  @"y":@(0.10),   @"z":@(-26.50)},
        @{@"n":@"Hot Zone",      @"e":@"🔥", @"x":@(31.00),  @"y":@(25.00),  @"z":@(-34.00)},
        @{@"n":@"Shop",          @"e":@"🛒", @"x":@(1.20),   @"y":@(7.00),   @"z":@(-34.50)},
        @{@"n":@"Spawn",         @"e":@"🌀", @"x":@(0.00),   @"y":@(6.00),   @"z":@(-10.00)},
        @{@"n":@"Center Spawn",  @"e":@"🎯", @"x":@(-1.00),  @"y":@(6.00),   @"z":@(-11.00)},
        @{@"n":@"Origin",        @"e":@"⭕", @"x":@(0.00),   @"y":@(0.00),   @"z":@(0.00)},
        @{@"n":@"Stash",         @"e":@"📦", @"x":@(-6.75),  @"y":@(1.00),   @"z":@(4.30)},
        @{@"n":@"Lake",          @"e":@"🌊", @"x":@(82.42),  @"y":@(1.88),   @"z":@(15.00)},
        @{@"n":@"Mountains",     @"e":@"⛰️", @"x":@(8.00),   @"y":@(42.00),  @"z":@(555.00)},
        @{@"n":@"Dupe Machine",  @"e":@"🌌", @"x":@(365.00), @"y":@(-431.00),@"z":@(-204.00)},
    ];

    NSArray *accentCycle = @[W_SUN, W_ORANGE, W_PINK, W_MINT, W_SKY, W_PURPLE,
                              W_SUN, W_ORANGE, W_PINK, W_MINT, W_SKY, W_PURPLE];

    for (int i = 0; i < (int)locs.count; i++) {
        NSDictionary *loc = locs[i];
        NSString *name = loc[@"n"], *emoji = loc[@"e"];
        float lx = [loc[@"x"] floatValue], ly = [loc[@"y"] floatValue], lz = [loc[@"z"] floatValue];

        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(10, y, w-20, 54);
        NSString *title = [NSString stringWithFormat:@"%@  %@\n      X:%.2f  Y:%.2f  Z:%.2f", emoji, name, lx, ly, lz];
        [b setTitle:title forState:UIControlStateNormal];
        [b setTitleColor:W_TEXT forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:12] ?: [UIFont boldSystemFontOfSize:12];
        b.titleLabel.numberOfLines = 2;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        b.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        b.backgroundColor = W_BTN;
        b.layer.cornerRadius = 12;
        b.layer.borderWidth = 1.2;
        UIColor *ac = accentCycle[i % accentCycle.count];
        b.layer.borderColor = ac.CGColor;
        b.layer.shadowColor = ac.CGColor;
        b.layer.shadowOpacity = 0.4; b.layer.shadowRadius = 6;

        objc_setAssociatedObject(b, "ln", name,  OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject(b, "lx", @(lx), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(b, "ly", @(ly), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(b, "lz", @(lz), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [b addTarget:self action:@selector(locTapped:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:b]; y += 62;
    }

    content.frame = CGRectMake(0,0,w,y+10);
    scroll.contentSize = content.frame.size;
    [scroll addSubview:content];
}

- (void)locTapped:(UIButton *)b {
    g_locName = objc_getAssociatedObject(b, "ln");
    g_x = [objc_getAssociatedObject(b, "lx") floatValue];
    g_y = [objc_getAssociatedObject(b, "ly") floatValue];
    g_z = [objc_getAssociatedObject(b, "lz") floatValue];

    _badge.text = [NSString stringWithFormat:@"📍  %@  (%.2f, %.2f, %.2f)", g_locName, g_x, g_y, g_z];

    [UIView animateWithDuration:0.15 animations:^{
        b.transform = CGAffineTransformMakeScale(0.96,0.96);
        b.layer.shadowOpacity = 0.9;
    } completion:^(BOOL d) {
        [UIView animateWithDuration:0.2 animations:^{
            b.transform = CGAffineTransformIdentity;
            b.layer.shadowOpacity = 0.4;
        }];
    }];
}
@end

// ═══════════════════════════════════════════════════════
// MAIN MENU VIEW CONTROLLER
// ═══════════════════════════════════════════════════════

@interface FridaysMenuVC : UIViewController <UITabBarDelegate>
@property (nonatomic, strong) UITabBar *tabBar;
@property (nonatomic, strong) WPlayerModsTab *playerTab;
@property (nonatomic, strong) WTrollingTab   *trollTab;
@property (nonatomic, strong) WExploitsTab   *exploitsTab;
@property (nonatomic, strong) WSpawningTab   *spawnTab;
@property (nonatomic, strong) WSettingsTab   *settingsTab;
@property (nonatomic, strong) UIView         *activeTab;
@end

@implementation FridaysMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBG];
    [self setupHeader];
    [self setupTabBar];
    [self setupTabs];
    [self showTab:self.spawnTab];
}

- (void)setupBG {
    // Sunny gradient
    CAGradientLayer *g = [CAGradientLayer layer]; g.frame = self.view.bounds;
    g.colors = @[(id)[UIColor colorWithRed:0.07 green:0.04 blue:0.16 alpha:1.0].CGColor,
                 (id)[UIColor colorWithRed:0.12 green:0.06 blue:0.22 alpha:1.0].CGColor,
                 (id)[UIColor colorWithRed:0.06 green:0.04 blue:0.14 alpha:1.0].CGColor];
    g.startPoint = CGPointMake(0,0); g.endPoint = CGPointMake(1,1);
    [self.view.layer insertSublayer:g atIndex:0];

    // Particles
    WParticleLayer *p = [[WParticleLayer alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:p];

    self.view.layer.cornerRadius = 20;
    self.view.layer.borderWidth = 2.0;
    self.view.layer.borderColor = W_SUN.CGColor;
    self.view.layer.shadowColor = W_ORANGE.CGColor;
    self.view.layer.shadowOpacity = 0.6; self.view.layer.shadowRadius = 20;
    self.view.clipsToBounds = YES;
}

- (void)setupHeader {
    CGFloat w = self.view.bounds.size.width;

    // Rainbow top bar
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0,0,w,4)];
    CAGradientLayer *bg = [CAGradientLayer layer]; bg.frame = bar.bounds;
    bg.colors = @[(id)W_PINK.CGColor,(id)W_ORANGE.CGColor,(id)W_SUN.CGColor,
                  (id)W_MINT.CGColor,(id)W_SKY.CGColor,(id)W_PURPLE.CGColor];
    bg.startPoint = CGPointMake(0,0.5); bg.endPoint = CGPointMake(1,0.5);
    [bar.layer addSublayer:bg]; [self.view addSubview:bar];

    // Flower decorations
    UILabel *flowers = [[UILabel alloc] initWithFrame:CGRectMake(0,7,w,18)];
    flowers.text = @"🌸  ✨  🌟  ✨  🌸";
    flowers.textAlignment = NSTextAlignmentCenter;
    flowers.font = [UIFont systemFontOfSize:13]; [self.view addSubview:flowers];

    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,26,w,24)];
    title.text = @"🌿  Friday's Menu  🌿";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:18] ?: [UIFont boldSystemFontOfSize:18];
    title.textColor = W_SUN;
    title.layer.shadowColor = W_ORANGE.CGColor;
    title.layer.shadowOpacity = 1.0; title.layer.shadowRadius = 12;
    [self.view addSubview:title];

    // Subtitle
    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(0,52,w,14)];
    sub.text = @"☀️  Animal Company  ☀️";
    sub.textAlignment = NSTextAlignmentCenter;
    sub.font = [UIFont fontWithName:@"AvenirNext-Medium" size:10] ?: [UIFont systemFontOfSize:10];
    sub.textColor = W_MINT;
    sub.layer.shadowColor = W_MINT.CGColor; sub.layer.shadowOpacity = 0.8; sub.layer.shadowRadius = 5;
    [self.view addSubview:sub];
}

- (void)setupTabBar {
    CGFloat w = self.view.bounds.size.width, h = self.view.bounds.size.height;
    _tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0,h-52,w,52)];
    _tabBar.barStyle = UIBarStyleBlack;
    _tabBar.translucent = YES;
    _tabBar.tintColor = W_SUN;
    _tabBar.delegate = self;
    _tabBar.backgroundColor = [UIColor colorWithRed:0.06 green:0.04 blue:0.14 alpha:0.97];

    // Rainbow tab bar top line
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0,0,w,2)];
    CAGradientLayer *tg = [CAGradientLayer layer]; tg.frame = topLine.bounds;
    tg.colors = @[(id)W_PINK.CGColor,(id)W_SUN.CGColor,(id)W_MINT.CGColor,(id)W_SKY.CGColor,(id)W_PURPLE.CGColor];
    tg.startPoint = CGPointMake(0,0.5); tg.endPoint = CGPointMake(1,0.5);
    [topLine.layer addSublayer:tg]; [_tabBar addSubview:topLine];

    UITabBarItem *t1 = [[UITabBarItem alloc] initWithTitle:@"Player" image:[UIImage systemImageNamed:@"person.fill"] tag:0];
    UITabBarItem *t2 = [[UITabBarItem alloc] initWithTitle:@"Troll" image:[UIImage systemImageNamed:@"bolt.fill"] tag:1];
    UITabBarItem *t3 = [[UITabBarItem alloc] initWithTitle:@"Exploits" image:[UIImage systemImageNamed:@"wand.and.stars"] tag:2];
    UITabBarItem *t4 = [[UITabBarItem alloc] initWithTitle:@"Spawn" image:[UIImage systemImageNamed:@"cube.box.fill"] tag:3];
    UITabBarItem *t5 = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage systemImageNamed:@"mappin.and.ellipse"] tag:4];
    _tabBar.items = @[t1,t2,t3,t4,t5];
    _tabBar.selectedItem = t4;
    [self.view addSubview:_tabBar];
}

- (void)setupTabs {
    CGFloat w = self.view.bounds.size.width, h = self.view.bounds.size.height;
    CGRect f = CGRectMake(0, 68, w, h - 68 - 52);
    _playerTab   = [[WPlayerModsTab alloc] initWithFrame:f];
    _trollTab    = [[WTrollingTab alloc] initWithFrame:f];
    _exploitsTab = [[WExploitsTab alloc] initWithFrame:f];
    _spawnTab    = [[WSpawningTab alloc] initWithFrame:f rootView:self.view];
    _settingsTab = [[WSettingsTab alloc] initWithFrame:f];
}

- (void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
    NSArray *tabs = @[_playerTab,_trollTab,_exploitsTab,_spawnTab,_settingsTab];
    [self showTab:tabs[item.tag]];
}

- (void)showTab:(UIView *)tab {
    [_activeTab removeFromSuperview];
    _activeTab = tab; tab.alpha = 0;
    [self.view insertSubview:tab atIndex:2];
    [UIView animateWithDuration:0.22 animations:^{ tab.alpha = 1; }];
}

@end

// ═══════════════════════════════════════════════════════
// FLOATING BUTTON
// ═══════════════════════════════════════════════════════

@interface FridaysMenuOverlay : NSObject @end
@implementation FridaysMenuOverlay
+ (void)install {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(16, 110, 56, 56);
        [btn setTitle:@"🌸" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:28];
        btn.backgroundColor = [UIColor colorWithRed:0.07 green:0.04 blue:0.16 alpha:0.95];
        btn.layer.cornerRadius = 28;
        btn.layer.borderWidth = 2.0;
        btn.layer.borderColor = W_SUN.CGColor;
        btn.layer.shadowColor = W_ORANGE.CGColor;
        btn.layer.shadowOpacity = 0.9; btn.layer.shadowRadius = 16;

        // Pulse glow
        CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        pulse.fromValue = @8; pulse.toValue = @22;
        pulse.duration = 1.2; pulse.autoreverses = YES; pulse.repeatCount = HUGE_VALF;
        [btn.layer addAnimation:pulse forKey:@"pulse"];

        // Color shift
        CABasicAnimation *colorShift = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        colorShift.fromValue = (id)W_SUN.CGColor;
        colorShift.toValue = (id)W_PINK.CGColor;
        colorShift.duration = 2.0; colorShift.autoreverses = YES; colorShift.repeatCount = HUGE_VALF;
        [btn.layer addAnimation:colorShift forKey:@"colorShift"];

        [btn addTarget:[FridaysMenuOverlay class] action:@selector(open) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
    });
}
+ (void)open {
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    FridaysMenuVC *menu = [[FridaysMenuVC alloc] init];
    menu.modalPresentationStyle = UIModalPresentationFormSheet;
    menu.preferredContentSize = CGSizeMake(340, 630);
    menu.view.transform = CGAffineTransformMakeScale(0.82,0.82);
    menu.view.alpha = 0;
    [root presentViewController:menu animated:NO completion:^{
        [UIView animateWithDuration:0.38 delay:0 usingSpringWithDamping:0.65
             initialSpringVelocity:0.6 options:0 animations:^{
            menu.view.transform = CGAffineTransformIdentity;
            menu.view.alpha = 1;
        } completion:nil];
    }];
}
@end

// ═══════════════════════════════════════════════════════
// CONSTRUCTOR
// ═══════════════════════════════════════════════════════

__attribute__((constructor))
static void initialize() {
    NSLog(@"[FridaysMenu] 🌸 Loaded. Welcome to Friday's Menu!");
    [FridaysMenuOverlay install];
}

