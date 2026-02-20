// FridaysMenu.m
// Animal Company Companion — "Friday's Menu"
// 3 Tabs: Exploits | Spawning | Settings (Locations)
//
// Compile:
//   clang -shared -o FridaysMenu.dylib FridaysMenu.m \
//         -framework UIKit -framework Foundation \
//         -framework QuartzCore -fobjc-arc
//
// Plist target: com.woosterGames.animalCompany

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

// ═══════════════════════════════════════════════════════
// SHARED STATE
// ═══════════════════════════════════════════════════════

static NSString *g_selectedLocationName = @"Spawn";
static float g_selectedX = 0.0f;
static float g_selectedY = 6.0f;
static float g_selectedZ = -10.0f;

// ═══════════════════════════════════════════════════════
// SEND COMMAND (mirrors companion app AI command system)
// ═══════════════════════════════════════════════════════

void sendCommand(NSString *cmd) {
    NSLog(@"[FridaysMenu] %@", cmd);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"ACCompanionSpawnCommand"
                      object:nil
                    userInfo:@{@"command": cmd}];
}

void spawnItem(NSString *item, NSInteger qty) {
    sendCommand([NSString stringWithFormat:@"hey ai spawn %@ %ld %.2f %.2f %.2f",
                 item, (long)qty, g_selectedX, g_selectedY, g_selectedZ]);
}

void spawnMob(NSString *mob) {
    sendCommand([NSString stringWithFormat:@"hey ai spawn mob %@ %.2f %.2f %.2f",
                 mob, g_selectedX, g_selectedY, g_selectedZ]);
}

// ═══════════════════════════════════════════════════════
// STAR BACKGROUND
// ═══════════════════════════════════════════════════════

@interface FStarLayer : UIView @end
@implementation FStarLayer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        NSArray *colors = @[
            [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:0.9],
            [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7],
            [UIColor colorWithRed:0.5 green:0.9 blue:1.0 alpha:0.8],
            [UIColor colorWithRed:1.0 green:0.5 blue:0.8 alpha:0.6],
        ];
        for (int i = 0; i < 40; i++) {
            CGFloat sz = (arc4random_uniform(3) + 1.5);
            UIView *s = [[UIView alloc] initWithFrame:CGRectMake(
                arc4random_uniform((uint32_t)frame.size.width),
                arc4random_uniform((uint32_t)frame.size.height), sz, sz)];
            s.layer.cornerRadius = sz / 2;
            s.backgroundColor = colors[i % 4];
            [self addSubview:s];
            CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"opacity"];
            a.fromValue = @(0.1); a.toValue = @(1.0);
            a.duration = 0.6 + (arc4random_uniform(25) / 10.0);
            a.autoreverses = YES; a.repeatCount = HUGE_VALF;
            a.beginTime = CACurrentMediaTime() + (arc4random_uniform(30) / 10.0);
            [s.layer addAnimation:a forKey:@"t"];
        }
    }
    return self;
}
@end

// ═══════════════════════════════════════════════════════
// HELPERS — section header, divider, button builder
// ═══════════════════════════════════════════════════════

UILabel *sectionHeader(NSString *title, CGFloat y, CGFloat w) {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(12, y, w - 24, 16)];
    l.text = title;
    l.textColor = [UIColor colorWithRed:0.5 green:0.85 blue:1.0 alpha:0.8];
    l.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:10] ?: [UIFont boldSystemFontOfSize:10];
    return l;
}

UIView *divider(CGFloat y, CGFloat w) {
    UIView *div = [[UIView alloc] initWithFrame:CGRectMake(12, y, w - 24, 0.5)];
    div.backgroundColor = [UIColor colorWithRed:0.5 green:0.85 blue:1.0 alpha:0.2];
    return div;
}

UIButton *actionBtn(NSString *title, UIColor *bgColor) {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:[UIColor colorWithRed:1.0 green:0.92 blue:0.65 alpha:1.0] forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13] ?: [UIFont boldSystemFontOfSize:13];
    b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    b.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    b.backgroundColor = bgColor ?: [UIColor colorWithRed:0.08 green:0.08 blue:0.18 alpha:0.9];
    b.layer.cornerRadius = 10;
    b.layer.borderWidth = 0.8;
    b.layer.borderColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.1 alpha:0.3].CGColor;
    b.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.5].CGColor;
    b.layer.shadowOpacity = 0.4; b.layer.shadowRadius = 5;
    b.layer.shadowOffset = CGSizeMake(0, 2);
    return b;
}

// ═══════════════════════════════════════════════════════
// QUANTITY PICKER POPUP
// ═══════════════════════════════════════════════════════

@interface FQtyPopup : UIView
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic) NSInteger quantity;
@end

@implementation FQtyPopup

- (instancetype)initWithFrame:(CGRect)frame item:(NSString *)item {
    self = [super initWithFrame:frame];
    if (self) {
        _itemName = item; _quantity = 1;
        self.backgroundColor = [UIColor colorWithRed:0.05 green:0.04 blue:0.14 alpha:0.98];
        self.layer.cornerRadius = 16;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.1 alpha:0.7].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.8; self.layer.shadowRadius = 20;
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    CGFloat w = self.bounds.size.width;

    // Location badge
    UILabel *locBadge = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, w - 20, 14)];
    locBadge.text = [NSString stringWithFormat:@"📍 %@  (%.1f, %.1f, %.1f)",
                     g_selectedLocationName, g_selectedX, g_selectedY, g_selectedZ];
    locBadge.textColor = [UIColor colorWithRed:0.5 green:0.85 blue:1.0 alpha:0.85];
    locBadge.font = [UIFont fontWithName:@"AvenirNext-Medium" size:9] ?: [UIFont systemFontOfSize:9];
    locBadge.textAlignment = NSTextAlignmentCenter;
    [self addSubview:locBadge];

    // Item name
    NSString *display = [[self.itemName stringByReplacingOccurrencesOfString:@"item_" withString:@""]
                          stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, w - 20, 20)];
    name.text = display;
    name.textColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.5 alpha:1.0];
    name.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14] ?: [UIFont boldSystemFontOfSize:14];
    name.textAlignment = NSTextAlignmentCenter;
    [self addSubview:name];

    // Qty display
    UILabel *ql = [[UILabel alloc] initWithFrame:CGRectMake(0, 52, w, 34)];
    ql.tag = 999; ql.text = @"x1";
    ql.textColor = [UIColor whiteColor];
    ql.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:28] ?: [UIFont boldSystemFontOfSize:28];
    ql.textAlignment = NSTextAlignmentCenter;
    ql.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0].CGColor;
    ql.layer.shadowOpacity = 0.8; ql.layer.shadowRadius = 8;
    [self addSubview:ql];

    // Qty buttons
    NSArray *qtys = @[@1, @5, @10, @50, @100];
    CGFloat bw = (w - 20) / qtys.count;
    for (int i = 0; i < (int)qtys.count; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(10 + i * bw, 90, bw - 4, 26);
        [b setTitle:[NSString stringWithFormat:@"x%@", qtys[i]] forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithRed:0.6 green:0.9 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11] ?: [UIFont boldSystemFontOfSize:11];
        b.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.25 alpha:1.0];
        b.layer.cornerRadius = 6;
        b.tag = [qtys[i] integerValue];
        [b addTarget:self action:@selector(setQty:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b];
    }

    // Spawn button
    UIButton *spawnBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    spawnBtn.frame = CGRectMake(14, 124, w - 28, 40);
    [spawnBtn setTitle:@"✦  SPAWN HERE  ✦" forState:UIControlStateNormal];
    [spawnBtn setTitleColor:[UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:1.0] forState:UIControlStateNormal];
    spawnBtn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:15] ?: [UIFont boldSystemFontOfSize:15];
    spawnBtn.backgroundColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:1.0];
    spawnBtn.layer.cornerRadius = 10;
    spawnBtn.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0].CGColor;
    spawnBtn.layer.shadowOpacity = 0.9; spawnBtn.layer.shadowRadius = 12;
    [spawnBtn addTarget:self action:@selector(doSpawn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:spawnBtn];

    // Cancel
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    cancel.frame = CGRectMake(14, 170, w - 28, 26);
    [cancel setTitle:@"✕  Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithRed:0.7 green:0.4 blue:0.4 alpha:1.0] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:12] ?: [UIFont systemFontOfSize:12];
    [cancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancel];
}

- (void)setQty:(UIButton *)s {
    self.quantity = s.tag;
    ((UILabel *)[self viewWithTag:999]).text = [NSString stringWithFormat:@"x%ld", (long)self.quantity];
}

- (void)doSpawn {
    spawnItem(self.itemName, self.quantity);
    UILabel *flash = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.bounds.size.width, 28)];
    flash.text = [NSString stringWithFormat:@"✦ Sent to %@ ✦", g_selectedLocationName];
    flash.textAlignment = NSTextAlignmentCenter;
    flash.textColor = [UIColor colorWithRed:0.4 green:1.0 blue:0.5 alpha:1.0];
    flash.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:13] ?: [UIFont boldSystemFontOfSize:13];
    flash.layer.shadowColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.4 alpha:1.0].CGColor;
    flash.layer.shadowOpacity = 1.0; flash.layer.shadowRadius = 10;
    [self addSubview:flash];
    [UIView animateWithDuration:0.3 animations:^{ flash.alpha = 1.0; } completion:^(BOOL d) {
        [UIView animateWithDuration:0.5 delay:0.8 options:0 animations:^{ flash.alpha = 0; }
            completion:^(BOOL dd) { [flash removeFromSuperview]; [self dismiss]; }];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0; self.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL d) { [self removeFromSuperview]; }];
}

@end

// ═══════════════════════════════════════════════════════
// TAB 1: EXPLOITS
// ═══════════════════════════════════════════════════════

@interface FExploitsTab : UIView @end
@implementation FExploitsTab

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        scroll.showsVerticalScrollIndicator = NO;
        scroll.backgroundColor = [UIColor clearColor];
        [self addSubview:scroll];

        UIView *content = [[UIView alloc] init];
        content.backgroundColor = [UIColor clearColor];
        CGFloat w = frame.size.width, y = 8;

        // ── SELF ──
        [content addSubview:sectionHeader(@"🛡️  SELF", y, w)]; y += 18;
        [content addSubview:divider(y, w)]; y += 8;

        NSDictionary *selfActions = @{
            @"🛡️  Invincibility (God Mode)":    @"hey ai god on",
            @"👻  Ghost Mode (Invisible)":       @"hey ai invisible on",
            @"🫧  Jellify Yourself":             @"hey ai jellify self",
            @"💨  Fart Boost":                  @"hey ai fart boost",
            @"🦨  Stink Jump":                  @"hey ai stink jump",
            @"🌕  Moon Teleport":               @"hey ai tp moon",
        };
        NSArray *selfOrder = @[@"🛡️  Invincibility (God Mode)", @"👻  Ghost Mode (Invisible)",
                               @"🫧  Jellify Yourself", @"💨  Fart Boost", @"🦨  Stink Jump", @"🌕  Moon Teleport"];
        for (NSString *title in selfOrder) {
            NSString *cmd = selfActions[title];
            UIButton *b = actionBtn(title, [UIColor colorWithRed:0.08 green:0.08 blue:0.2 alpha:0.9]);
            b.frame = CGRectMake(10, y, w - 20, 40);
            [b addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:b]; y += 46;
        }

        // ── PLAYER EFFECTS ──
        y += 4;
        [content addSubview:sectionHeader(@"⚡  PLAYER EFFECTS (ALL)", y, w)]; y += 18;
        [content addSubview:divider(y, w)]; y += 8;

        NSDictionary *playerActions = @{
            @"🌈  Disco Players":               @"hey ai rainbow players on",
            @"🌈  Disco Monsters":              @"hey ai rainbow monsters on",
            @"🗿  Big Head Everyone":           @"hey ai bighead all",
            @"🩷  Pink Haze (All Screens)":     @"hey ai screen pink",
            @"🩸  Blood Screen (All)":          @"hey ai screen red",
            @"🔇  Muffle All Voices":           @"hey ai voice muffle",
            @"🐭  Squeaky Voices":              @"hey ai voice squeak",
            @"📳  Shake All Screens":           @"hey ai shake",
            @"💥  Mega Earthquake":             @"hey ai shake insane",
            @"⚡  Super Speed (All)":           @"hey ai speed all",
        };
        NSArray *playerOrder = @[@"🌈  Disco Players", @"🌈  Disco Monsters", @"🗿  Big Head Everyone",
                                 @"🩷  Pink Haze (All Screens)", @"🩸  Blood Screen (All)",
                                 @"🔇  Muffle All Voices", @"🐭  Squeaky Voices",
                                 @"📳  Shake All Screens", @"💥  Mega Earthquake", @"⚡  Super Speed (All)"];
        for (NSString *title in playerOrder) {
            NSString *cmd = playerActions[title];
            UIButton *b = actionBtn(title, [UIColor colorWithRed:0.1 green:0.05 blue:0.22 alpha:0.9]);
            b.frame = CGRectMake(10, y, w - 20, 40);
            objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:b]; y += 46;
        }

        // ── DAMAGE ──
        y += 4;
        [content addSubview:sectionHeader(@"☠️  DAMAGE & CHAOS", y, w)]; y += 18;
        [content addSubview:divider(y, w)]; y += 8;

        NSDictionary *dmgActions = @{
            @"💀  Wipe Lobby (Kill All Players)":  @"hey ai kill all players",
            @"👾  Annihilate All Monsters":        @"hey ai kill all monsters",
            @"🧊  Freeze Everyone":                @"hey ai stun all",
            @"🦨  Stink Bomb (All Players)":       @"hey ai stink all",
            @"🚀  Hyper Launch Everyone":          @"hey ai launch all",
            @"🌀  Fling All Players":              @"hey ai fling all",
            @"🕳️  Void Drop (TP to Death Zone)":  @"hey ai tp all death",
            @"🧲  Recall All Players to Me":       @"hey ai teleport all to me",
        };
        NSArray *dmgOrder = @[@"💀  Wipe Lobby (Kill All Players)", @"👾  Annihilate All Monsters",
                              @"🧊  Freeze Everyone", @"🦨  Stink Bomb (All Players)",
                              @"🚀  Hyper Launch Everyone", @"🌀  Fling All Players",
                              @"🕳️  Void Drop (TP to Death Zone)", @"🧲  Recall All Players to Me"];
        for (NSString *title in dmgOrder) {
            NSString *cmd = dmgActions[title];
            UIButton *b = actionBtn(title, [UIColor colorWithRed:0.22 green:0.03 blue:0.03 alpha:0.9]);
            b.frame = CGRectMake(10, y, w - 20, 40);
            objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:b]; y += 46;
        }

        // ── MONEY ──
        y += 4;
        [content addSubview:sectionHeader(@"💰  MONEY", y, w)]; y += 18;
        [content addSubview:divider(y, w)]; y += 8;

        NSDictionary *moneyActions = @{
            @"♾️  Infinite Wallet (99M)":         @"hey ai money 99999999",
            @"💰  Give Self 9,999,999 Coins":     @"hey ai money 9999999",
            @"🪙  Give Self 1,000 Coins":         @"hey ai money 1000",
            @"🎰  Explode Money Machine":         @"hey ai explode money machine",
            @"🌧️  Ammo Rain (All Players)":       @"hey ai spawn ammo giveaway",
            @"🔩  Nut Drop (All Players)":        @"hey ai spawn nut giveaway",
            @"🎁  Gift Car Drop":                 @"hey ai spawn gift car",
        };
        NSArray *moneyOrder = @[@"♾️  Infinite Wallet (99M)", @"💰  Give Self 9,999,999 Coins",
                                @"🪙  Give Self 1,000 Coins", @"🎰  Explode Money Machine",
                                @"🌧️  Ammo Rain (All Players)", @"🔩  Nut Drop (All Players)", @"🎁  Gift Car Drop"];
        for (NSString *title in moneyOrder) {
            NSString *cmd = moneyActions[title];
            UIButton *b = actionBtn(title, [UIColor colorWithRed:0.22 green:0.15 blue:0.0 alpha:0.9]);
            b.frame = CGRectMake(10, y, w - 20, 40);
            objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:b]; y += 46;
        }

        // ── BUFFS ──
        y += 4;
        [content addSubview:sectionHeader(@"✨  BUFFS", y, w)]; y += 18;
        [content addSubview:divider(y, w)]; y += 8;

        NSArray *buffs = @[@"Speedboost", @"Bloodlust", @"Bounce", @"Grow", @"Shrink", @"Fling", @"Kick", @"Love", @"Illness"];
        for (NSString *buff in buffs) {
            NSString *cmd = [NSString stringWithFormat:@"hey ai buff %@", buff];
            UIButton *b = actionBtn([NSString stringWithFormat:@"⚡  %@", buff],
                                    [UIColor colorWithRed:0.1 green:0.04 blue:0.24 alpha:0.9]);
            b.frame = CGRectMake(10, y, w - 20, 40);
            objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:b]; y += 46;
        }
        UIButton *allBuffs = actionBtn(@"✨  Apply ALL Buffs", [UIColor colorWithRed:0.2 green:0.0 blue:0.3 alpha:0.9]);
        allBuffs.frame = CGRectMake(10, y, w - 20, 40);
        [allBuffs addTarget:self action:@selector(applyAllBuffs) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:allBuffs]; y += 46;

        // ── ADVANCED ──
        y += 4;
        [content addSubview:sectionHeader(@"🔐  ADVANCED", y, w)]; y += 18;
        [content addSubview:divider(y, w)]; y += 8;

        NSDictionary *advActions = @{
            @"⫸  Void Stash (Heavy Stick)":          @"hey ai spawn heavystick",
            @"🪨  Ultra Heavy Stick Backpack":        @"hey ai spawn heavystick backpack",
            @"🌈  Rainbow Quiver Stick":              @"hey ai spawn colorstick quiver",
            @"🌀  Portal Grenade Backpack":           @"hey ai spawn telegrenade backpack",
            @"🛸  No Gravity (All Items)":            @"hey ai no gravity items",
            @"🤖  Spawn Robo Army":                  @"hey ai spawn robomonke",
            @"⬆️  Bounce Backpack Trap":             @"hey ai spawn bounce backpack",
            @"🗑️  Delete All World Items":            @"hey ai delete all items",
        };
        NSArray *advOrder = @[@"⫸  Void Stash (Heavy Stick)", @"🪨  Ultra Heavy Stick Backpack",
                              @"🌈  Rainbow Quiver Stick", @"🌀  Portal Grenade Backpack",
                              @"🛸  No Gravity (All Items)", @"🤖  Spawn Robo Army",
                              @"⬆️  Bounce Backpack Trap", @"🗑️  Delete All World Items"];
        for (NSString *title in advOrder) {
            NSString *cmd = advActions[title];
            UIButton *b = actionBtn(title, [UIColor colorWithRed:0.04 green:0.1 blue:0.22 alpha:0.9]);
            b.frame = CGRectMake(10, y, w - 20, 40);
            objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
            [b addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [content addSubview:b]; y += 46;
        }

        content.frame = CGRectMake(0, 0, w, y + 10);
        scroll.contentSize = content.frame.size;
        [scroll addSubview:content];
    }
    return self;
}

- (void)btnTapped:(UIButton *)sender {
    NSString *cmd = objc_getAssociatedObject(sender, "cmd");
    if (cmd) sendCommand(cmd);
    [UIView animateWithDuration:0.08 animations:^{ sender.transform = CGAffineTransformMakeScale(0.95,0.95); }
        completion:^(BOOL d){ [UIView animateWithDuration:0.1 animations:^{ sender.transform = CGAffineTransformIdentity; }]; }];
}

- (void)applyAllBuffs {
    for (NSString *b in @[@"Speedboost",@"Bloodlust",@"Bounce",@"Grow"])
        sendCommand([NSString stringWithFormat:@"hey ai buff %@", b]);
}

@end

// ═══════════════════════════════════════════════════════
// TAB 2: SPAWNING (Items + Mobs)
// ═══════════════════════════════════════════════════════

@interface FSpawningTab : UIView <UISearchBarDelegate>
@property (nonatomic, strong) NSArray *allItems, *filtered;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIScrollView *itemScroll;
@property (nonatomic, strong) UIView *itemContent;
@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, strong) UISegmentedControl *seg;
@property (nonatomic, strong) UIView *mobsView;
@end

@implementation FSpawningTab

- (instancetype)initWithFrame:(CGRect)frame rootView:(UIView *)root {
    self = [super initWithFrame:frame];
    if (self) {
        _rootView = root;
        self.backgroundColor = [UIColor clearColor];
        [self buildItemList];
        [self buildUI];
    }
    return self;
}

- (void)buildItemList {
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
        @"item_quest_hlal_brain",@"item_quest_hlal_eyeball",@"item_quest_hlal_flesh",@"item_quest_hlal_heart",
        @"item_quest_key_graveyard",
        @"item_quest_vhs",@"item_quest_vhs_backlots",@"item_quest_vhs_basement",
        @"item_quest_vhs_cave",@"item_quest_vhs_circus_day",@"item_quest_vhs_circus_ext",
        @"item_quest_vhs_circus_fac",@"item_quest_vhs_dam_facility",@"item_quest_vhs_dam_servers",
        @"item_quest_vhs_dark_forest",@"item_quest_vhs_forest",@"item_quest_vhs_foundation",
        @"item_quest_vhs_graveyard",@"item_quest_vhs_haunted_house",@"item_quest_vhs_hell",
        @"item_quest_vhs_lab",@"item_quest_vhs_lake",@"item_quest_vhs_lobby",@"item_quest_vhs_mines",
        @"item_quest_vhs_mountain",@"item_quest_vhs_mountainbot",@"item_quest_vhs_mountainshack",
        @"item_quest_vhs_mountainvault",@"item_quest_vhs_office",@"item_quest_vhs_office_basement",
        @"item_quest_vhs_powerplant_microwave",@"item_quest_vhs_powerplant_reactorcore",
        @"item_quest_vhs_powerplant_security",@"item_quest_vhs_powerplant_supportfacility",
        @"item_quest_vhs_sewers",
        @"item_revolver_ammo",@"item_shotgun_ammo",@"item_rpg_ammo",
        @"item_rpg_ammo_egg",@"item_rpg_ammo_spear",
        @"item_arrow",@"item_arrow_heart",@"item_arrow_lightbulb",@"item_arrow_teleport",
        @"item_quiver",@"item_quiver_heart",
        @"item_randombox_base",@"item_randombox_mobloot_big",@"item_randombox_mobloot_medium",
        @"item_randombox_mobloot_small",@"item_randombox_mobloot_weapons",@"item_randombox_mobloot_zombie",
        @"item_umbrella",@"item_umbrella_clover",@"item_umbrella_squirrel",
        @"item_toilet_paper",@"item_toilet_paper_mega",@"item_toilet_paper_roll_empty",
        @"item_boot",@"item_egg",@"item_coconut_shell",@"item_ring_buoy",
        @"item_upsidedown_loot",@"item_pumpkinjack",@"item_pumpkinjack_small",
        @"item_metal_rod_xmas",@"item_metal_plate_xmas",@"item_metal_ball_xmas",
        @"item_steel_beam_xmas",@"item_truss_xmas",@"item_rpg_easter",@"item_pickaxe_cny",@"item_rpg_cny",
    ];
    _filtered = _allItems;
}

- (void)buildUI {
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;

    // Segment: Items / Mobs
    _seg = [[UISegmentedControl alloc] initWithItems:@[@"📦  Items", @"🧟  Mobs"]];
    _seg.frame = CGRectMake(10, 6, w - 20, 32);
    _seg.selectedSegmentIndex = 0;
    _seg.tintColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:1.0];
    if (@available(iOS 13.0, *)) {
        _seg.selectedSegmentTintColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.0 alpha:1.0];
        [_seg setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:1.0]} forState:UIControlStateSelected];
        [_seg setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.8 green:0.8 blue:0.9 alpha:1.0]} forState:UIControlStateNormal];
    }
    [_seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_seg];

    // Search bar (items only)
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 44, w - 20, 34)];
    _searchBar.placeholder = @"🔍 Search items...";
    _searchBar.barStyle = UIBarStyleBlack;
    _searchBar.translucent = YES;
    _searchBar.delegate = self;
    _searchBar.layer.cornerRadius = 8;
    _searchBar.clipsToBounds = YES;
    [self addSubview:_searchBar];

    // Items scroll
    _itemScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 84, w, h - 84)];
    _itemScroll.showsVerticalScrollIndicator = NO;
    _itemScroll.backgroundColor = [UIColor clearColor];
    [self addSubview:_itemScroll];
    _itemContent = [[UIView alloc] init];
    _itemContent.backgroundColor = [UIColor clearColor];
    [_itemScroll addSubview:_itemContent];
    [self rebuildItems];

    // Mobs view (hidden initially)
    _mobsView = [self buildMobsView:CGRectMake(0, 44, w, h - 44)];
    _mobsView.hidden = YES;
    [self addSubview:_mobsView];
}

- (UIView *)buildMobsView:(CGRect)frame {
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:frame];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.backgroundColor = [UIColor clearColor];
    UIView *content = [[UIView alloc] init];
    CGFloat w = frame.size.width, y = 8;

    NSArray *monsters = @[
        @"👁️  Angler",@"😡  AnglerMad",@"💪  Armstrong",@"😡  ArmstrongMad",@"👻  Banshee",
        @"🗿  BigHead",@"🫧  Blob",@"💣  Bomb",@"💥  Bomber",@"💥  BomberFlashbang",
        @"😡  BomberMad",@"🐔  Chicken",@"🥰  Cutie",@"🦠  Cyst",@"👁️  EvilEye",
        @"👁️  EvilEyePinata",@"👁️  EvilEyePinataLarge",@"🦍  FakeGorilla",@"🪲  FlyingSwarm",
        @"🌲  ForestMob",@"👹  Giant",@"💀  Giant_GraveyardBoss",@"🧟  HordeMob",
        @"🦒  Lanky",@"🪞  Mimic",@"🤖  NextBot",@"🤖  NextBotStatic",@"👻  Phantom",
        @"🫀  PolypMass",@"🎭  Puppet",@"🔴  RedGreen",@"😡  RedGreenMad",
        @"🎪  Ringmaster",@"🤖  RoboMonke",@"🐕  RobotDog",@"🛴  Segway",
        @"👤  Shadow",@"🕷️  SpiderCave",@"🕷️  Spider",@"⚡  Thunder",@"🐛  TubeMonster",
    ];

    [content addSubview:sectionHeader(@"🧟  MONSTERS", y, w)]; y += 18;
    [content addSubview:divider(y, w)]; y += 8;

    for (NSString *fullTitle in monsters) {
        NSString *mobName = [[fullTitle componentsSeparatedByString:@"  "] lastObject];
        UIButton *b = actionBtn(fullTitle, [UIColor colorWithRed:0.12 green:0.04 blue:0.2 alpha:0.9]);
        b.frame = CGRectMake(10, y, w - 20, 40);
        objc_setAssociatedObject(b, "mob", mobName, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [b addTarget:self action:@selector(mobTapped:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:b]; y += 46;
    }

    [content addSubview:sectionHeader(@"🏗️  WORLD OBJECTS", y, w)]; y += 18;
    [content addSubview:divider(y, w)]; y += 8;

    NSArray *prefabs = @[
        @"🎄  ChristmasBox",@"🎄  ChristmasBoxManager",@"🍌  BigBanana",@"🔥  BonfireController",
        @"🕹️  ClawMachineNetObject",@"🌌  Duplicator",@"🥚  ExplosiveEgg",@"🥚  ExplosiveEggClustered",
        @"🔮  FortuneTellerNet",@"📦  GenericWorldItemSpawner",@"🪨  GiantRockObject",
        @"🔥  GiantRockObject_Fire",@"😈  HellAltar",@"🎈  InflatedBalloon",@"🎈  InflatedHeartBalloon",
        @"💸  ItemSellingMachineController",@"🏮  LootLantern",@"🎬  MovieTheater",@"🚗  Vehicle_Buggy",
    ];

    for (NSString *fullTitle in prefabs) {
        NSString *pfName = [[fullTitle componentsSeparatedByString:@"  "] lastObject];
        NSString *cmd = [NSString stringWithFormat:@"hey ai spawn prefab %@ %.2f %.2f %.2f",
                         pfName, g_selectedX, g_selectedY, g_selectedZ];
        UIButton *b = actionBtn(fullTitle, [UIColor colorWithRed:0.04 green:0.1 blue:0.2 alpha:0.9]);
        b.frame = CGRectMake(10, y, w - 20, 40);
        objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [b addTarget:self action:@selector(prefabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:b]; y += 46;
    }

    content.frame = CGRectMake(0, 0, w, y + 10);
    scroll.contentSize = content.frame.size;
    [scroll addSubview:content];
    return scroll;
}

- (void)mobTapped:(UIButton *)sender {
    NSString *mob = objc_getAssociatedObject(sender, "mob");
    if (mob) spawnMob(mob);
    [UIView animateWithDuration:0.08 animations:^{ sender.transform = CGAffineTransformMakeScale(0.95,0.95); }
        completion:^(BOOL d){ [UIView animateWithDuration:0.1 animations:^{ sender.transform = CGAffineTransformIdentity; }]; }];
}

- (void)prefabTapped:(UIButton *)sender {
    NSString *cmd = objc_getAssociatedObject(sender, "cmd");
    if (cmd) sendCommand(cmd);
    [UIView animateWithDuration:0.08 animations:^{ sender.transform = CGAffineTransformMakeScale(0.95,0.95); }
        completion:^(BOOL d){ [UIView animateWithDuration:0.1 animations:^{ sender.transform = CGAffineTransformIdentity; }]; }];
}

- (void)segChanged:(UISegmentedControl *)seg {
    BOOL isItems = seg.selectedSegmentIndex == 0;
    _searchBar.hidden = !isItems;
    _itemScroll.hidden = !isItems;
    _mobsView.hidden = isItems;
}

- (NSString *)emojiFor:(NSString *)item {
    if ([item containsString:@"apple"]||[item containsString:@"banana"]||[item containsString:@"cola"]||
        [item containsString:@"turkey"]||[item containsString:@"popcorn"]||[item containsString:@"burrito"]||
        [item containsString:@"ration"]||[item containsString:@"cocoa"]||[item containsString:@"cracker"]||
        [item containsString:@"pineapple"]||[item containsString:@"cheese"]||[item containsString:@"pie"]||
        [item containsString:@"meat"]||[item containsString:@"egg"]||[item containsString:@"mug"]||[item containsString:@"cup"])
        return @"🍎";
    if ([item containsString:@"rpg"]||[item containsString:@"shotgun"]||[item containsString:@"pistol"]||
        [item containsString:@"revolver"]||[item containsString:@"flamethrower"]||[item containsString:@"crossbow"]||
        [item containsString:@"radiation"]||[item containsString:@"moneygun"]||[item containsString:@"arena"]||
        [item containsString:@"flaregun"]||[item containsString:@"launcher"])
        return @"🔫";
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
        [item containsString:@"pickaxe"]||[item containsString:@"hoverpad"]||[item containsString:@"zipline"]||[item containsString:@"key"])
        return @"🔦";
    if ([item containsString:@"snowboard"]||[item containsString:@"snowball"]||[item containsString:@"ski"]||
        [item containsString:@"football"]||[item containsString:@"trampoline"]) return @"⛷️";
    if ([item containsString:@"boombox"]||[item containsString:@"ukulele"]||[item containsString:@"drum"]||
        [item containsString:@"theremin"]||[item containsString:@"balloon"]||[item containsString:@"disc"]||
        [item containsString:@"glowstick"]||[item containsString:@"rubberducky"]||[item containsString:@"kissy"])
        return @"🎵";
    if ([item containsString:@"fish"]||[item containsString:@"rod"]||[item containsString:@"carp"]||[item containsString:@"crappie"])
        return @"🎣";
    if ([item containsString:@"shield"]||[item containsString:@"ogre"]||[item containsString:@"bloodlust"]) return @"🛡️";
    if ([item containsString:@"xmas"]||[item containsString:@"easter"]||[item containsString:@"halloween"]||
        [item containsString:@"pumpkin"]||[item containsString:@"cny"]||[item containsString:@"clover"]) return @"🎄";
    if ([item containsString:@"ammo"]||[item containsString:@"arrow"]||[item containsString:@"quiver"]) return @"🏹";
    return @"📦";
}

- (void)rebuildItems {
    for (UIView *v in _itemContent.subviews) [v removeFromSuperview];
    CGFloat w = self.bounds.size.width, pad = 10, btnH = 40, y = 6;
    for (NSString *item in _filtered) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(pad, y, w - pad*2, btnH);
        NSString *display = [[item stringByReplacingOccurrencesOfString:@"item_" withString:@""]
                              stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        [btn setTitle:[NSString stringWithFormat:@"%@  %@", [self emojiFor:item], display] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:1.0 green:0.92 blue:0.65 alpha:1.0] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13] ?: [UIFont boldSystemFontOfSize:13];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        btn.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.18 alpha:0.85];
        btn.layer.cornerRadius = 10; btn.layer.borderWidth = 0.8;
        btn.layer.borderColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.1 alpha:0.3].CGColor;
        btn.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.4].CGColor;
        btn.layer.shadowOpacity = 0.4; btn.layer.shadowRadius = 5; btn.layer.shadowOffset = CGSizeMake(0,2);
        btn.accessibilityLabel = item;
        [btn addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_itemContent addSubview:btn]; y += btnH + 6;
    }
    _itemContent.frame = CGRectMake(0, 0, w, y + 10);
    _itemScroll.contentSize = _itemContent.frame.size;
}

- (void)itemTapped:(UIButton *)sender {
    UIView *root = self.rootView ?: self;
    FQtyPopup *popup = [[FQtyPopup alloc]
        initWithFrame:CGRectMake(root.bounds.size.width/2 - 150, root.bounds.size.height/2 - 110, 300, 210)
                 item:sender.accessibilityLabel];
    popup.alpha = 0; popup.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [root addSubview:popup];
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:0 animations:^{
        popup.alpha = 1.0; popup.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)text {
    _filtered = text.length == 0 ? _allItems :
        [_allItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text]];
    [self rebuildItems];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)sb { [sb resignFirstResponder]; }

@end

// ═══════════════════════════════════════════════════════
// TAB 3: SETTINGS (Locations)
// ═══════════════════════════════════════════════════════

@interface FSettingsTab : UIView
@property (nonatomic, strong) UILabel *activeBadge;
@end

@implementation FSettingsTab

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    CGFloat w = self.bounds.size.width;
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    scroll.showsVerticalScrollIndicator = NO;
    scroll.backgroundColor = [UIColor clearColor];
    [self addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    content.backgroundColor = [UIColor clearColor];
    CGFloat y = 8;

    // Active location badge
    _activeBadge = [[UILabel alloc] initWithFrame:CGRectMake(10, y, w - 20, 36)];
    _activeBadge.text = [NSString stringWithFormat:@"📍  Active: %@  (%.2f, %.2f, %.2f)",
                         g_selectedLocationName, g_selectedX, g_selectedY, g_selectedZ];
    _activeBadge.textColor = [UIColor colorWithRed:0.4 green:1.0 blue:0.5 alpha:1.0];
    _activeBadge.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:11] ?: [UIFont boldSystemFontOfSize:11];
    _activeBadge.textAlignment = NSTextAlignmentCenter;
    _activeBadge.backgroundColor = [UIColor colorWithRed:0.05 green:0.15 blue:0.05 alpha:0.8];
    _activeBadge.layer.cornerRadius = 8;
    _activeBadge.layer.borderWidth = 1.0;
    _activeBadge.layer.borderColor = [UIColor colorWithRed:0.4 green:1.0 blue:0.5 alpha:0.4].CGColor;
    _activeBadge.clipsToBounds = YES;
    _activeBadge.numberOfLines = 1;
    _activeBadge.adjustsFontSizeToFitWidth = YES;
    [content addSubview:_activeBadge]; y += 44;

    [content addSubview:sectionHeader(@"📍  CHOOSE SPAWN LOCATION", y, w)]; y += 18;
    [content addSubview:divider(y, w)]; y += 10;

    // All your locations
    NSArray *locations = @[
        @{@"name": @"Sell",           @"emoji": @"💸", @"x": @(-14.50), @"y": @(4.00),   @"z": @(-23.50)},
        @{@"name": @"Stage 5",        @"emoji": @"🎭", @"x": @(-5.00),  @"y": @(3.00),   @"z": @(-160.00)},
        @{@"name": @"Toilet",         @"emoji": @"🚽", @"x": @(-6.00),  @"y": @(0.10),   @"z": @(-26.50)},
        @{@"name": @"Hot Zone",       @"emoji": @"🔥", @"x": @(31.00),  @"y": @(25.00),  @"z": @(-34.00)},
        @{@"name": @"Shop",           @"emoji": @"🛒", @"x": @(1.20),   @"y": @(7.00),   @"z": @(-34.50)},
        @{@"name": @"Spawn",          @"emoji": @"🌀", @"x": @(0.00),   @"y": @(6.00),   @"z": @(-10.00)},
        @{@"name": @"Center Spawn",   @"emoji": @"🎯", @"x": @(-1.00),  @"y": @(6.00),   @"z": @(-11.00)},
        @{@"name": @"Origin",         @"emoji": @"⭕", @"x": @(0.00),   @"y": @(0.00),   @"z": @(0.00)},
        @{@"name": @"Stash",          @"emoji": @"📦", @"x": @(-6.75),  @"y": @(1.00),   @"z": @(4.30)},
        @{@"name": @"Lake",           @"emoji": @"🌊", @"x": @(82.42),  @"y": @(1.88),   @"z": @(15.00)},
        @{@"name": @"Mountains",      @"emoji": @"⛰️", @"x": @(8.00),   @"y": @(42.00),  @"z": @(555.00)},
        @{@"name": @"Dupe Machine",   @"emoji": @"🌌", @"x": @(365.00), @"y": @(-431.00),@"z": @(-204.00)},
        @{@"name": @"Lobby",          @"emoji": @"🏠", @"x": @(0.00),   @"y": @(6.00),   @"z": @(-10.00)},
        @{@"name": @"Ski Hill",       @"emoji": @"⛷️", @"x": @(120.00), @"y": @(60.00),  @"z": @(200.00)},
        @{@"name": @"Planetarium",    @"emoji": @"🌟", @"x": @(-80.00), @"y": @(20.00),  @"z": @(300.00)},
        @{@"name": @"Graveyard",      @"emoji": @"⚰️", @"x": @(200.00), @"y": @(5.00),   @"z": @(-50.00)},
        @{@"name": @"Haunted House",  @"emoji": @"👻", @"x": @(180.00), @"y": @(8.00),   @"z": @(-80.00)},
        @{@"name": @"Sewers",         @"emoji": @"🌀", @"x": @(30.00),  @"y": @(-10.00), @"z": @(80.00)},
        @{@"name": @"Mines",          @"emoji": @"⛏️", @"x": @(-100.00),@"y": @(-20.00), @"z": @(150.00)},
        @{@"name": @"Death Zone",     @"emoji": @"💀", @"x": @(0.00),   @"y": @(-500.00),@"z": @(0.00)},
        @{@"name": @"Moon Map",       @"emoji": @"🌕", @"x": @(0.00),   @"y": @(200.00), @"z": @(500.00)},
    ];

    for (NSDictionary *loc in locations) {
        NSString *name  = loc[@"name"];
        NSString *emoji = loc[@"emoji"];
        float lx = [loc[@"x"] floatValue];
        float ly = [loc[@"y"] floatValue];
        float lz = [loc[@"z"] floatValue];

        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(10, y, w - 20, 50);
        NSString *coords = [NSString stringWithFormat:@"X:%.2f  Y:%.2f  Z:%.2f", lx, ly, lz];
        NSString *btnTitle = [NSString stringWithFormat:@"%@  %@\n      %@", emoji, name, coords];
        [b setTitle:btnTitle forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithRed:1.0 green:0.92 blue:0.65 alpha:1.0] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:12] ?: [UIFont boldSystemFontOfSize:12];
        b.titleLabel.numberOfLines = 2;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        b.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        b.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.18 alpha:0.85];
        b.layer.cornerRadius = 10; b.layer.borderWidth = 0.8;
        b.layer.borderColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.1 alpha:0.3].CGColor;
        b.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.4].CGColor;
        b.layer.shadowOpacity = 0.35; b.layer.shadowRadius = 5;

        // Store values
        objc_setAssociatedObject(b, "locName",  name,  OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject(b, "locX",     @(lx), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(b, "locY",     @(ly), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(b, "locZ",     @(lz), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [b addTarget:self action:@selector(locTapped:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:b]; y += 56;
    }

    content.frame = CGRectMake(0, 0, w, y + 10);
    scroll.contentSize = content.frame.size;
    [scroll addSubview:content];
}

- (void)locTapped:(UIButton *)sender {
    NSString *name = objc_getAssociatedObject(sender, "locName");
    g_selectedLocationName = name;
    g_selectedX = [objc_getAssociatedObject(sender, "locX") floatValue];
    g_selectedY = [objc_getAssociatedObject(sender, "locY") floatValue];
    g_selectedZ = [objc_getAssociatedObject(sender, "locZ") floatValue];

    // Flash selected
    [UIView animateWithDuration:0.15 animations:^{
        sender.backgroundColor = [UIColor colorWithRed:0.2 green:0.15 blue:0.0 alpha:1.0];
        sender.transform = CGAffineTransformMakeScale(0.97, 0.97);
    } completion:^(BOOL d) {
        [UIView animateWithDuration:0.2 animations:^{
            sender.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.18 alpha:0.85];
            sender.transform = CGAffineTransformIdentity;
        }];
    }];

    // Update badge
    _activeBadge.text = [NSString stringWithFormat:@"📍  Active: %@  (%.2f, %.2f, %.2f)",
                         g_selectedLocationName, g_selectedX, g_selectedY, g_selectedZ];
    [UIView animateWithDuration:0.3 animations:^{
        self->_activeBadge.backgroundColor = [UIColor colorWithRed:0.0 green:0.2 blue:0.05 alpha:0.9];
    } completion:^(BOOL d) {
        [UIView animateWithDuration:0.5 animations:^{
            self->_activeBadge.backgroundColor = [UIColor colorWithRed:0.05 green:0.15 blue:0.05 alpha:0.8];
        }];
    }];
}

@end

// ═══════════════════════════════════════════════════════
// MAIN MENU VIEW CONTROLLER
// ═══════════════════════════════════════════════════════

@interface FridaysMenuVC : UIViewController <UITabBarDelegate>
@property (nonatomic, strong) UITabBar *tabBar;
@property (nonatomic, strong) FExploitsTab  *exploitsTab;
@property (nonatomic, strong) FSpawningTab  *spawningTab;
@property (nonatomic, strong) FSettingsTab  *settingsTab;
@property (nonatomic, strong) UIView        *currentTabView;
@end

@implementation FridaysMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    [self setupHeader];
    [self setupTabBar];
    [self setupTabViews];
    [self showTab:self.spawningTab];
}

- (void)setupBackground {
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = self.view.bounds;
    g.colors = @[(id)[UIColor colorWithRed:0.03 green:0.02 blue:0.12 alpha:1.0].CGColor,
                 (id)[UIColor colorWithRed:0.07 green:0.03 blue:0.18 alpha:1.0].CGColor,
                 (id)[UIColor colorWithRed:0.04 green:0.07 blue:0.14 alpha:1.0].CGColor];
    g.startPoint = CGPointMake(0, 0); g.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:g atIndex:0];
    [self.view addSubview:[[FStarLayer alloc] initWithFrame:self.view.bounds]];
    self.view.layer.cornerRadius = 18;
    self.view.layer.borderWidth = 1.5;
    self.view.layer.borderColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.1 alpha:0.55].CGColor;
    self.view.clipsToBounds = YES;
}

- (void)setupHeader {
    CGFloat w = self.view.bounds.size.width;
    // Gold top bar
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 3)];
    CAGradientLayer *bg = [CAGradientLayer layer]; bg.frame = bar.bounds;
    bg.colors = @[(id)[UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0].CGColor,
                  (id)[UIColor colorWithRed:1.0 green:0.85 blue:0.1 alpha:1.0].CGColor,
                  (id)[UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0].CGColor];
    bg.startPoint = CGPointMake(0, 0.5); bg.endPoint = CGPointMake(1, 0.5);
    [bar.layer addSublayer:bg]; [self.view addSubview:bar];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, w, 22)];
    title.text = @"✦  👑  Friday's Menu  👑  ✦";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:15] ?: [UIFont boldSystemFontOfSize:15];
    title.textColor = [UIColor colorWithRed:1.0 green:0.88 blue:0.4 alpha:1.0];
    title.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0].CGColor;
    title.layer.shadowOpacity = 1.0; title.layer.shadowRadius = 10;
    [self.view addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, w, 14)];
    sub.text = @"🌙 Animal Company 🌙";
    sub.textAlignment = NSTextAlignmentCenter;
    sub.font = [UIFont fontWithName:@"AvenirNext-Medium" size:9] ?: [UIFont systemFontOfSize:9];
    sub.textColor = [UIColor colorWithRed:0.5 green:0.85 blue:1.0 alpha:0.85];
    sub.layer.shadowColor = [UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:1.0].CGColor;
    sub.layer.shadowOpacity = 0.8; sub.layer.shadowRadius = 6;
    [self.view addSubview:sub];
}

- (void)setupTabBar {
    CGFloat w = self.view.bounds.size.width, h = self.view.bounds.size.height;
    self.tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, h - 50, w, 50)];
    self.tabBar.barStyle = UIBarStyleBlack;
    self.tabBar.translucent = YES;
    self.tabBar.tintColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:1.0];
    self.tabBar.delegate = self;
    self.tabBar.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.12 alpha:0.97];

    UITabBarItem *t1 = [[UITabBarItem alloc] initWithTitle:@"Exploits" image:[UIImage systemImageNamed:@"wand.and.stars"] tag:0];
    UITabBarItem *t2 = [[UITabBarItem alloc] initWithTitle:@"Spawning" image:[UIImage systemImageNamed:@"cube.box.fill"] tag:1];
    UITabBarItem *t3 = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage systemImageNamed:@"mappin.and.ellipse"] tag:2];
    self.tabBar.items = @[t1, t2, t3];
    self.tabBar.selectedItem = t2;
    [self.view addSubview:self.tabBar];
}

- (void)setupTabViews {
    CGFloat w = self.view.bounds.size.width, h = self.view.bounds.size.height;
    CGRect tabFrame = CGRectMake(0, 46, w, h - 46 - 50);
    self.exploitsTab = [[FExploitsTab alloc] initWithFrame:tabFrame];
    self.spawningTab = [[FSpawningTab alloc] initWithFrame:tabFrame rootView:self.view];
    self.settingsTab = [[FSettingsTab alloc] initWithFrame:tabFrame];
}

- (void)tabBar:(UITabBar *)tb didSelectItem:(UITabBarItem *)item {
    NSArray *tabs = @[self.exploitsTab, self.spawningTab, self.settingsTab];
    [self showTab:tabs[item.tag]];
}

- (void)showTab:(UIView *)tab {
    [self.currentTabView removeFromSuperview];
    self.currentTabView = tab;
    tab.alpha = 0;
    [self.view insertSubview:tab atIndex:2];
    [UIView animateWithDuration:0.2 animations:^{ tab.alpha = 1.0; }];
}

@end

// ═══════════════════════════════════════════════════════
// FLOATING 🌙 BUTTON
// ═══════════════════════════════════════════════════════

@interface FridaysMenuOverlay : NSObject @end
@implementation FridaysMenuOverlay
+ (void)install {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(16, 110, 54, 54);
        [btn setTitle:@"🌙" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:26];
        btn.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.14 alpha:0.93];
        btn.layer.cornerRadius = 27;
        btn.layer.borderWidth = 1.5;
        btn.layer.borderColor = [UIColor colorWithRed:1.0 green:0.75 blue:0.1 alpha:0.75].CGColor;
        btn.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0].CGColor;
        btn.layer.shadowOpacity = 0.85; btn.layer.shadowRadius = 14;
        CABasicAnimation *p = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
        p.fromValue = @8; p.toValue = @20; p.duration = 1.4;
        p.autoreverses = YES; p.repeatCount = HUGE_VALF;
        [btn.layer addAnimation:p forKey:@"pulse"];
        [btn addTarget:[FridaysMenuOverlay class] action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
        [win addSubview:btn];
    });
}
+ (void)openMenu {
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    FridaysMenuVC *menu = [[FridaysMenuVC alloc] init];
    menu.modalPresentationStyle = UIModalPresentationFormSheet;
    menu.preferredContentSize = CGSizeMake(340, 620);
    menu.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
    menu.view.alpha = 0;
    [root presentViewController:menu animated:NO completion:^{
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.7
             initialSpringVelocity:0.5 options:0 animations:^{
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
    NSLog(@"[FridaysMenu] 🌙 Loaded.");
    [FridaysMenuOverlay install];
}
