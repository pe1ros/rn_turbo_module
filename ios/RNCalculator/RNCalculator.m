//
//  RNCalculator.m
//  RNCalculator
//
//  Created by Ilya Petrosyan on 25.04.2022.
//

#import "RNCalculator.h"

@implementation RNCalculator

RCT_EXPORT_MODULE(Calculator)

RCT_REMAP_METHOD(add, addA:(NSInteger)a
                        andB:(NSInteger)b
                withResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
    NSNumber *result = [[NSNumber alloc] initWithInteger:a+b];
    resolve(result);
}

@end
