//
//  Factory.h
//  toycameraeffector
//
//  Created by h f on 12/05/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiUtils.h"

@interface Factory : NSObject
{
@private
    size_t width_;
    size_t height_;
    size_t bitsPerComponent_;
    size_t bitsPerPixel_;
    size_t bytesPerRow_;
    CGColorSpaceRef colorSpace_;
    CGBitmapInfo bitmapInfo_;
    bool shouldInterpolate_;
    CGColorRenderingIntent intent_;
    CGDataProviderRef dataProvider_;
    CFDataRef data_;
    UInt8 *buffer_;
}
-(id)initWidthImage:(UIImage *)image;
-(UIImage *)createImage;
-(void)grayscale;
-(void)histogramStretch;
-(void)sigmoid:(NSInteger)gammaint;
-(void)modulateHSV:(NSInteger)hue:(NSInteger)saturation:(NSInteger)brightness;
-(void)darkenlimb:(CGFloat)start:(CGFloat)end;
-(void)emphasize:(CGFloat)alpha:(CGFloat)start:(CGFloat)end;
@end

typedef struct {
    UInt8 r;
    UInt8 g;
    UInt8 b;
    UInt8 a;
} Pixcel;

#define GET_PIXEL(_p, _x, _y) \
    _p.r = *((buffer_ + _y*bytesPerRow_ + _x*4) + 0); \
    _p.g = *((buffer_ + _y*bytesPerRow_ + _x*4) + 1); \
    _p.b = *((buffer_ + _y*bytesPerRow_ + _x*4) + 2); \
    _p.a = *((buffer_ + _y*bytesPerRow_ + _x*4) + 3); \

#define SET_PIXEL(_p, _x, _y) \
    *((buffer_ + _y*bytesPerRow_ + _x*4) + 0) = _p.r; \
    *((buffer_ + _y*bytesPerRow_ + _x*4) + 1) = _p.g; \
    *((buffer_ + _y*bytesPerRow_ + _x*4) + 2) = _p.b; \
    *((buffer_ + _y*bytesPerRow_ + _x*4) + 3) = _p.a;
