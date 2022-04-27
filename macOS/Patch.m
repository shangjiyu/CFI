@import ObjectiveC;
@import Foundation;
@import AppKit;

__attribute__((warn_unused_result)) IMP ReplaceMethod(SEL selector, IMP newImpl, Class affectedClass, BOOL isClassMethod);

IMP ReplaceMethod(SEL selector, IMP newImpl, Class affectedClass, BOOL isClassMethod) {
    Method origMethod = isClassMethod ? class_getClassMethod(affectedClass, selector) : class_getInstanceMethod(affectedClass, selector);
    IMP origImpl = method_getImplementation(origMethod);
    if (!class_addMethod(isClassMethod ? object_getClass(affectedClass) : affectedClass, selector, newImpl, method_getTypeEncoding(origMethod))) {
        method_setImplementation(origMethod, newImpl);
    }
    return origImpl;
}

typedef id(*NavigationSplitViewController_ViewWillAppear) (id, SEL);
static NavigationSplitViewController_ViewWillAppear origin_viewWillAppear;
static void patch_viewWillAppear(id self, SEL _cmd)
{
    origin_viewWillAppear(self, _cmd);
    NSSplitViewController *vc = (NSSplitViewController *)self;
    vc.view.window.styleMask = vc.view.window.styleMask & (~NSWindowStyleMaskResizable);
    for (NSSplitViewItem *item in vc.splitViewItems) {
        item.canCollapse = NO;
    }
    [[vc.splitView.arrangedSubviews.firstObject.widthAnchor constraintEqualToConstant:240] setActive:YES];
    [[vc.splitView.arrangedSubviews.lastObject.widthAnchor constraintEqualToConstant:540] setActive:YES];
}

@interface PatchEntry: NSObject
@end

@implementation PatchEntry

+ (void)load {
    {
        Class clazz = NSClassFromString(@"SwiftUI.NavigationSplitViewController");
        SEL sel = NSSelectorFromString(@"viewWillAppear");
        IMP imp = (IMP)patch_viewWillAppear;
        origin_viewWillAppear = (NavigationSplitViewController_ViewWillAppear)ReplaceMethod(sel, imp, clazz, false);
    }
}

@end
