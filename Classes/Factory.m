//
//  Factory.m
//  toycameraeffector
//
//  Created by h f on 12/05/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Factory.h"

@implementation Factory

-(id)init
{
    [super init];
    
    return self;
}

-(id)initWidthImage:(UIImage *)image
{
    [self init];
    
    CGImageRef imageRef = [image CGImage];
    
    width_ = CGImageGetWidth(imageRef);
    height_ = CGImageGetHeight(imageRef);
    bitsPerComponent_ = CGImageGetBitsPerComponent(imageRef);
    bitsPerPixel_ = CGImageGetBitsPerPixel(imageRef);
    bytesPerRow_ = CGImageGetBytesPerRow(imageRef);
    colorSpace_ = CGImageGetColorSpace(imageRef);
    bitmapInfo_ = CGImageGetBitmapInfo(imageRef);
    shouldInterpolate_ = CGImageGetShouldInterpolate(imageRef);
    intent_ = CGImageGetRenderingIntent(imageRef);
    dataProvider_ = CGImageGetDataProvider(imageRef);
    data_ = CGDataProviderCopyData(dataProvider_);
    buffer_ = (UInt8*)CFDataGetBytePtr(data_);
    
    return self;
}

-(void)dealloc
{
    CFRelease(data_);
    
    [super dealloc];
}

-(UIImage *)createImage
{
    CFDataRef effectedData = CFDataCreate(NULL, buffer_, CFDataGetLength(data_));
    CGDataProviderRef effectDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    CGImageRef effectedCgImage;
    UIImage *effectedImage, *tmpImage;
    effectedCgImage = CGImageCreate(width_, 
                                    height_, 
                                    bitsPerComponent_,
                                    bitsPerPixel_,
                                    bytesPerRow_,
                                    colorSpace_,
                                    bitmapInfo_,
                                    effectDataProvider,
                                    NULL,
                                    shouldInterpolate_,
                                    intent_);
    
    effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    CGImageRelease(effectedCgImage);
    CFRelease(effectDataProvider);
    CFRelease(effectedData);

    return effectedImage;
}


-(void)grayscale
{
    NSUInteger x, y;
    UInt8 brightness;
    Pixcel pix;
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            brightness = (77 * pix.r + 28 * pix.g + 151 * pix.b) / 256;
            
            pix.r = brightness;
            pix.g = brightness;
            pix.b = brightness;
            
            SET_PIXEL(pix, x, y);
        }
    }
}

-(void)histogramStretch
{
    NSUInteger x, y;
    NSInteger rmax, rmin, gmax, gmin, bmax, bmin;
    NSInteger pval;
    Pixcel pix;
    
    rmax = gmax = bmax = 0;
    rmin = gmin = bmin = 255;
    
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            if (rmax < pix.r) rmax = pix.r;
            else if (rmin > pix.r) rmin = pix.r;
            
            if (gmax < pix.g) gmax = pix.g;
            else if (gmin > pix.g) gmin = pix.g;
            
            if (bmax < pix.b) bmax = pix.b;
            else if (bmin > pix.b) bmin = pix.b;
        }
    }
    
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            pix.r = 255 * (pix.r - rmin) / (rmax - rmin);
            pix.g = 255 * (pix.g - gmin) / (gmax - gmin);
            pix.b = 255 * (pix.b - bmin) / (bmax - bmin);
            
            SET_PIXEL(pix, x, y);
        }
    }
}

-(void)sigmoid:(NSInteger)gammaint
{
    NSUInteger x, y;
    NSInteger i;
    double gamma;
    double a;
    int color_tbl[256];
    Pixcel pix;
    
    gamma = (double)gammaint / 10.0;
    
    for (i = 0; i < 256; i++)
    {
        a = ((double)(i - 128) / 255.0) * gamma;
        color_tbl[i] = (int)(255.0 / (1.0 + exp(-a)));
        
        if (color_tbl[i] > 255)
        {
            color_tbl[i] = 255;
        }
    }
    
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            pix.r = color_tbl[pix.r];
            pix.g = color_tbl[pix.g];
            pix.b = color_tbl[pix.b];
            
            SET_PIXEL(pix, x, y);
        }
    }
}

-(void)RGBtoHSV:(int)r:(int)g:(int)b:(float *)h:(float *)s:(float *)v
{
    float rr, gg, bb;
    float hh, ss, vv;
    float cmax, cmin, cdes;
    
    rr = (float)r / 255.0f;
    gg = (float)g / 255.0f;
    bb = (float)b / 255.0f;
    
    cmax = MAX(MAX(rr, gg), bb);
    cmin = MIN(MIN(rr, gg), bb);
    cdes = cmax - cmin;
    
    if (cmax == 0.0f)
    {
        hh = 0.0;
        ss = 0.0;
        vv = 0.0;
    }
    else if (cdes == 0.0f)
    {
        hh = 0.0;
        ss = 0.0;
        vv = cmax;
    }
    else
    {
        ss = cdes / cmax;
        vv = cmax;
        
        if (cmax == rr)
        {
            hh = 60.0f * ((gg - bb) / cdes);
        }
        else if (cmax == gg)
        {
            hh = 60.0f * (2.0f + (bb - rr) / cdes);
        }
        else if (cmax == bb)
        {
            hh = 60.0f * (4.0f + (rr - gg) / cdes);
        }
        
        if (hh < 0.0f) hh = hh + 360.0f;
    }
    
    *h = hh;
    *s = ss;
    *v = vv;
}

-(void)HSVtoRGB:(float)h:(float)s:(float)v:(int *)r:(int *)g:(int *)b
{
    float rr, gg, bb;
    
    if (s == 0.0)
    {
        rr = gg = bb = v;
    }
    else
    {
        int hi = (int)floor(h / 60.0);
        if (hi < 0) hi = hi * -1;
        float f = (h / 60.0) - hi;
        float p = v * (1.0 - s);
        float q = v * (1.0 - s * f);
        float t = v * (1.0 - s * (1.0 - f));
        
        switch (hi)
        {
            case 0:
                rr = v;
                gg = t;
                bb = p;
                break;
            case 1:
                rr = q;
                gg = v;
                bb = p;
                break;
            case 2:
                rr = p;
                gg = v;
                bb = q;
                break;
            case 3:
                rr = p;
                gg = q;
                bb = v;
                break;
            case 4:
                rr = t;
                gg = p;
                bb = v;
                break;
            case 5:
                rr = v;
                gg = p;
                bb = q;
                break;
            default:
                NSLog(@"[ERROR] %@ HSVtoRGB ERROR: %d",self, hi);
                break;
        }
    }
    
    *r = rr * 255.0;
    *g = gg * 255.0;
    *b = bb * 255.0;
}

-(void)modulateHSV:(NSInteger)hue:(NSInteger)saturation:(NSInteger)brightness
{
    NSUInteger x, y;
    int rr, gg, bb;
    float hh, ss, vv;
    Pixcel pix;
    
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            rr = pix.r;
            gg = pix.g;
            bb = pix.b;
            
            [self RGBtoHSV:rr:gg:bb:&hh:&ss:&vv];
            
            if (hue != 100)
            {
                hh = fmodf(hh + 180.0f * (hue - 100), 360.0f);
            }
            
            if (saturation != 100)
            {
                ss = ss * ((float)saturation / 100.0f);
                if (ss > 1.0f) ss = 1.0f;
            }
            
            if (brightness != 100)
            {
                vv = vv * ((float)brightness / 100.0f);
                if (vv > 1.0f) vv = 1.0f;
            }
            
            [self HSVtoRGB:hh:ss:vv:&rr:&gg:&bb];
            
            pix.r = rr;
            pix.g = gg;
            pix.b = bb;
            
            SET_PIXEL(pix, x, y);
        }
    }
}

-(void)darkenlimb:(CGFloat)start:(CGFloat)end
{
    NSUInteger x, y;
    NSInteger d, dx, dy;
    float alpha;
    
    size_t len = width_ > height_ ? width_ : height_;
    CGFloat rs = len * start / 2;
    CGFloat re = len * end / 2;
    CGFloat rw = re - rs;
    NSInteger center_x = width_ / 2;
    NSInteger center_y = height_ / 2;
    
    Pixcel pix;
    
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            // 中心点からの距離を算出
            dx = abs(center_x - x);
            dy = abs(center_y - y);
            d = round(sqrtf((dx*dx) + (dy*dy)));
            
            if (d > rs)
            {
                if (d < re)
                {
                    alpha = 1.0f - ((d - rs) / rw);
                    pix.r = pix.r * alpha;
                    pix.g = pix.g * alpha;
                    pix.b = pix.b * alpha;
                }
                else
                {
                    pix.r = 0;
                    pix.g = 0;
                    pix.b = 0;
                }
                
                SET_PIXEL(pix, x, y);
            }
        }
    }
}

-(void)emphasize:(CGFloat)alpha:(CGFloat)start:(CGFloat)end
{
    NSUInteger x, y;
    NSInteger d, dx, dy;
    float a;
    
    size_t len = width_ > height_ ? width_ : height_;
    CGFloat rs = len * start / 2;
    CGFloat re = len * end / 2;
    CGFloat rw = re - rs;
    NSInteger center_x = width_ / 2;
    NSInteger center_y = height_ / 2;
    
    Pixcel pix;
    
    for (y = 0; y < height_; y++)
    {
        for (x = 0; x < width_; x++)
        {
            GET_PIXEL(pix, x, y);
            
            // 中心点からの距離を算出
            dx = abs(center_x - x);
            dy = abs(center_y - y);
            d = round(sqrtf((dx*dx) + (dy*dy)));
            
            if (d < re)
            {
                if (d > rs)
                {
                    a = (1.0f - ((d - rs) / rw)) * alpha;
                }
                else
                {
                    a = alpha;
                }
                pix.r = (pix.r * (1.0f - a)) + (255.0f * a);
                pix.g = (pix.g * (1.0f - a)) + (255.0f * a);
                pix.b = (pix.b * (1.0f - a)) + (255.0f * a);
                
                SET_PIXEL(pix, x, y);
            }
        }
    }
}



@end












