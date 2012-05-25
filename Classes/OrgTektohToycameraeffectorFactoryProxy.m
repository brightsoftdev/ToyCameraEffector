//
//  OrgTektohToycameraeffectorFactoryProxy.m
//  toycameraeffector
//
//  Created by h f on 12/05/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OrgTektohToycameraeffectorFactoryProxy.h"

@implementation OrgTektohToycameraeffectorFactoryProxy


-(id)init
{
    factory_ = nil;
    
    NSLog(@"[INFO] %@ created",self);
    
    return self;
}

-(void)dealloc
{
    RELEASE_TO_NIL(factory_);
    [super dealloc];
}

-(void)setImage:(id)value
{
    TiBlob *blob = value;
    factory_ = [[Factory alloc] initWidthImage:blob.image];
}

-(id)image
{
    UIImage *image = [factory_ createImage];

    TiBlob *blob =  [[[TiBlob alloc] initWithImage:image] autorelease];
    
    [image release];
    
    return blob;
}

-(id)grayscale:(id)args
{
    NSLog(@"[INFO] %@ grayscale()",self);

    [factory_ grayscale];

    return self;
}

-(id)histogramStretch:(id)args
{
    NSLog(@"[INFO] %@ histogramStretch()",self);
    
    [factory_ histogramStretch];
    return self;
}

-(id)sigmoid:(id)args
{
    NSInteger gammaint = [TiUtils intValue:[args objectAtIndex:0]];
    
    NSLog(@"[INFO] %@ sigmoid(%d)",self,gammaint);
    
    [factory_ sigmoid:gammaint];
    
    return self;
}

-(id)modulateHSV:(id)args
{
    id arg;
    ENSURE_SINGLE_ARG(args, NSDictionary);

    arg = [args objectForKey:@"hue"];
    NSInteger hue = [TiUtils intValue:arg def:100];
    
    arg = [args objectForKey:@"saturation"];
    NSInteger saturation = [TiUtils intValue:arg def:100];
    
    arg = [args objectForKey:@"brightness"];
    NSInteger brightness = [TiUtils intValue:arg def:100];
    
    NSLog(@"[INFO] %@ modulateSaturation(%d,%d,%d)",self,hue,saturation,brightness);
    
    [factory_ modulateHSV:hue :saturation :brightness];
    
    return self;
}

-(id)darkenlimb:(id)args
{
    CGFloat start = [TiUtils floatValue:[args objectAtIndex:0] def:0.0f];
    CGFloat end = [TiUtils floatValue:[args objectAtIndex:1] def:0.0f];
    
    if (start > end)
    {
        NSLog(@"[ERROR] %@ darkenlimb(%f,%f): start > end",self,start,end);
        return self;
    }
    
    NSLog(@"[INFO] %@ darkenlimb(%d,%d)",self,start, end);
    
    [factory_ darkenlimb:start :end];
    
    return self;
}

-(id)emphasize:(id)args
{
    CGFloat alpha = [TiUtils floatValue:[args objectAtIndex:0] def:0.0f];
    CGFloat start = [TiUtils floatValue:[args objectAtIndex:1] def:0.0f];
    CGFloat end = [TiUtils floatValue:[args objectAtIndex:2] def:0.0f];
    
    if (alpha > 1.0f || alpha < 0.0f)
    {
        NSLog(@"[ERROR] %@ emphasize(%f,%f,%f)",self,alpha,start,end);
        return self;
    }
    
    if (start > end)
    {
        NSLog(@"[ERROR] %@ emphasize(%f,%f,%f): start > end",self,alpha,start,end);
        return self;
    }
    
    NSLog(@"[INFO] %@ emphasize(%f,%f,%f)",self,alpha,start,end);
    
    [factory_ emphasize:alpha :start :end];
    
    return self;
}


@end













