//
//  NSObject+MessageForward.m
//  HFHookMessageForward
//
//  Created by hui hong on 2019/1/23.
//  Copyright © 2019 hui hong. All rights reserved.
//

#import "NSObject+MessageForward.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

IMP impWithSelecctor(SEL aSelector) {
    return imp_implementationWithBlock(^(){
        NSLog(@"未实现方法【%@】，消息转发call stack is %@", NSStringFromSelector(aSelector), [NSThread callStackSymbols]);
        [[[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"出错啦~, 未实现方法[%@], 详情看log~", NSStringFromSelector(aSelector)]
                                   delegate:nil
                          cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    });
}

@interface MessageForward : NSObject
@end
@implementation MessageForward
@end

@implementation NSObject (MessageForward)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这种容易hook系统的方法
        //        Method oriMethod = class_getInstanceMethod([self class], @selector(forwardingTargetForSelector:));
        //        Method newMethod = class_getInstanceMethod([self class], @selector(hf_forwardingTargetForSelector:));
        //        method_exchangeImplementations(oriMethod, newMethod);
        
        method_exchangeImplementations(class_getInstanceMethod([self class], @selector(methodSignatureForSelector:)),
                                       class_getInstanceMethod([self class], @selector(hf_methodSignatureForSelector:)));
        
        method_exchangeImplementations(class_getInstanceMethod([self class], @selector(forwardInvocation:)),
                                       class_getInstanceMethod([self class], @selector(hf_forwardInvocation:)));
    });
}

- (NSMethodSignature *)hf_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sign = [self hf_methodSignatureForSelector:aSelector];
    if (!sign) {
        if (![MessageForward instancesRespondToSelector:aSelector]) {
            class_addMethod(MessageForward.class, aSelector, impWithSelecctor(aSelector), "v:@");
        }
        sign = [MessageForward instanceMethodSignatureForSelector:aSelector];
    }
    return sign;
}

- (void)hf_forwardInvocation:(NSInvocation *)anInvocation {
    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:anInvocation.target];
    } else if ([MessageForward instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:[MessageForward new]];
    } else {
        [self hf_forwardInvocation:anInvocation];
    }
}

@end
