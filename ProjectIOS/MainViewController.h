//
//  MainViewController.h
//  LGSideMenuControllerDemo
//

#import "LGSideMenuController.h"

@interface MainViewController : LGSideMenuController



typedef NS_ENUM(NSInteger, LGSideMenuStyle)
{
    TypeScaleFromBig,
    TypeSlideAbove,
    TypeSlideBelow,
    TypeScaleFromLittle,
    TypeBlurredRootViewCover,
    TypeBlurredSideViewCover,
    TypeBlurredSideViewBackgrounds,
    TypeLandscapeAlwaysVisible,
    TypeStatusBarAlwaysVisible,
    TypeGestureAreaFull,
    TypeEditableTable,
    TypeCustom,
    TypeSlideAboveLeftOnly,
    TypeSlideAboveRightOnly
};

- (void)setupWithType:(LGSideMenuStyle)type;

@end
