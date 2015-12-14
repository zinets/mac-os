//
//  UIBlurredImageView.m
//  testHorTable
//
//  Created by Zinetz Victor on 22.04.13.
//  Copyright (c) 2013 Cupid plc. All rights reserved.
//

#import "UIBlurredImageView.h"

@interface UIBlurredImageView () {
    UIImageView * blurLayer;
}

@end

@implementation UIBlurredImageView

-(UIImage *) rgb32image:(UIImage *)source {
    int width = source.size.width;
    int height = source.size.height;
    CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef thumbBitmapCtxt = CGBitmapContextCreate(NULL,
                                                         width,
                                                         height,
                                                         8, (4 * width),
                                                         genericColorSpace,
                                                         kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(genericColorSpace);
    CGContextSetInterpolationQuality(thumbBitmapCtxt, kCGInterpolationDefault);
    CGRect destRect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(thumbBitmapCtxt, destRect, source.CGImage);
    CGImageRef tmpThumbImage = CGBitmapContextCreateImage(thumbBitmapCtxt);
    CGContextRelease(thumbBitmapCtxt);
    UIImage *result = [UIImage imageWithCGImage:tmpThumbImage];
    CGImageRelease(tmpThumbImage);
    
    return result;
}

#define SQUARE(i) ((i)*(i))

inline static
void zeroClearInt (int * p, size_t count) {
    memset(p, 0, sizeof(int) * count);
}

void applyStackBlurToBuffer (UInt8 * targetBuffer, const int w, const int h, NSUInteger inradius) {
	const int radius = inradius;
	const int wm = w - 1;
	const int hm = h - 1;
	const int wh = w*h;
	const int div = radius + radius + 1;
	const int r1 = radius + 1;
	const int divsum = SQUARE((div+1)>>1);
    
	int stack[div*3];
	zeroClearInt(stack, div*3);
    
	int vmin[MAX(w,h)];
	zeroClearInt(vmin, MAX(w,h));
    
	int *r = malloc(wh*sizeof(int));
	int *g = malloc(wh*sizeof(int));
	int *b = malloc(wh*sizeof(int));
	zeroClearInt(r, wh);
	zeroClearInt(g, wh);
	zeroClearInt(b, wh);
    
    const size_t dvcount = 256 * divsum;
    int *dv = malloc(sizeof(int) * dvcount);
	for (int i = 0;i < dvcount;i++) {
		dv[i] = (i / divsum);
	}
    
    int x, y;
	int *sir;
	int routsum,goutsum,boutsum;
	int rinsum,ginsum,binsum;
	int rsum, gsum, bsum, p, yp;
	int stackpointer;
	int stackstart;
	int rbs;
    
	int yw = 0, yi = 0;
	for (y = 0;y < h;y++) {
		rinsum = ginsum = binsum = routsum = goutsum = boutsum = rsum = gsum = bsum = 0;
		
		for(int i = -radius;i <= radius;i++){
			sir = &stack[(i + radius)*3];
			int offset = (yi + MIN(wm, MAX(i, 0)))*4;
			sir[0] = targetBuffer[offset];
			sir[1] = targetBuffer[offset + 1];
			sir[2] = targetBuffer[offset + 2];
			
			rbs = r1 - abs(i);
			rsum += sir[0] * rbs;
			gsum += sir[1] * rbs;
			bsum += sir[2] * rbs;
			if (i > 0){
				rinsum += sir[0];
				ginsum += sir[1];
				binsum += sir[2];
			} else {
				routsum += sir[0];
				goutsum += sir[1];
				boutsum += sir[2];
			}
		}
		stackpointer = radius;
		
		for (x = 0;x < w;x++) {
			r[yi] = dv[rsum];
			g[yi] = dv[gsum];
			b[yi] = dv[bsum];
			
			rsum -= routsum;
			gsum -= goutsum;
			bsum -= boutsum;
			
			stackstart = stackpointer - radius + div;
			sir = &stack[(stackstart % div)*3];
			
			routsum -= sir[0];
			goutsum -= sir[1];
			boutsum -= sir[2];
			
			if (y == 0){
				vmin[x] = MIN(x + radius + 1, wm);
			}
			
			int offset = (yw + vmin[x])*4;
			sir[0] = targetBuffer[offset];
			sir[1] = targetBuffer[offset + 1];
			sir[2] = targetBuffer[offset + 2];
			rinsum += sir[0];
			ginsum += sir[1];
			binsum += sir[2];
			
			rsum += rinsum;
			gsum += ginsum;
			bsum += binsum;
			
			stackpointer = (stackpointer + 1) % div;
			sir = &stack[(stackpointer % div)*3];
			
			routsum += sir[0];
			goutsum += sir[1];
			boutsum += sir[2];
			
			rinsum -= sir[0];
			ginsum -= sir[1];
			binsum -= sir[2];
			
			yi++;
		}
		yw += w;
	}
    
	for (x = 0;x < w;x++) {
		rinsum = ginsum = binsum = routsum = goutsum = boutsum = rsum = gsum = bsum = 0;
		yp = -radius*w;
		for(int i = -radius;i <= radius;i++) {
			yi = MAX(0, yp) + x;
			
			sir = &stack[(i + radius)*3];
			
			sir[0] = r[yi];
			sir[1] = g[yi];
			sir[2] = b[yi];
			
			rbs = r1 - abs(i);
			
			rsum += r[yi]*rbs;
			gsum += g[yi]*rbs;
			bsum += b[yi]*rbs;
			
			if (i > 0) {
				rinsum += sir[0];
				ginsum += sir[1];
				binsum += sir[2];
			} else {
				routsum += sir[0];
				goutsum += sir[1];
				boutsum += sir[2];
			}
			
			if (i < hm) {
				yp += w;
			}
		}
		yi = x;
		stackpointer = radius;
		for (y = 0;y < h;y++) {
			int offset = yi*4;
			targetBuffer[offset]     = dv[rsum];
			targetBuffer[offset + 1] = dv[gsum];
			targetBuffer[offset + 2] = dv[bsum];
			rsum -= routsum;
			gsum -= goutsum;
			bsum -= boutsum;
			
			stackstart = stackpointer - radius + div;
			sir = &stack[(stackstart % div)*3];
			
			routsum -= sir[0];
			goutsum -= sir[1];
			boutsum -= sir[2];
			
			if (x == 0){
				vmin[y] = MIN(y + r1, hm)*w;
			}
			p = x + vmin[y];
			
			sir[0] = r[p];
			sir[1] = g[p];
			sir[2] = b[p];
			
			rinsum += sir[0];
			ginsum += sir[1];
			binsum += sir[2];
			
			rsum += rinsum;
			gsum += ginsum;
			bsum += binsum;
			
			stackpointer = (stackpointer + 1) % div;
			sir = &stack[stackpointer*3];
			
			routsum += sir[0];
			goutsum += sir[1];
			boutsum += sir[2];
			
			rinsum -= sir[0];
			ginsum -= sir[1];
			binsum -= sir[2];
			
			yi += w;
		}
	}
    
	free(r);
	free(g);
	free(b);
    free(dv);
}

#pragma mark - 

-(void)addBlurLayer {
    if (blurLayer) {
        [blurLayer removeFromSuperview];
        blurLayer = nil;
    }

    if (_blurRadius < 1){
		return;
	}
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        blurLayer = [[UIImageView alloc] initWithFrame:self.bounds];
        blurLayer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurLayer.contentMode = self.contentMode;
        
        CGImageRef inImage = self.image.CGImage;
        int nbPerCompt = CGImageGetBitsPerPixel(inImage);
        if(nbPerCompt != 32){
            UIImage *tmpImage = [self rgb32image:self.image];
            inImage = tmpImage.CGImage;
        }
        CFMutableDataRef m_DataRef = CFDataCreateMutableCopy(0, 0, CGDataProviderCopyData(CGImageGetDataProvider(inImage)));
        UInt8 * m_PixelBuf = malloc(CFDataGetLength(m_DataRef));
        CFDataGetBytes(m_DataRef,
                       CFRangeMake(0, CFDataGetLength(m_DataRef)) ,
                       m_PixelBuf);
        
        CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
                                                 CGImageGetWidth(inImage),
                                                 CGImageGetHeight(inImage),
                                                 CGImageGetBitsPerComponent(inImage),
                                                 CGImageGetBytesPerRow(inImage),
                                                 CGImageGetColorSpace(inImage),
                                                 CGImageGetBitmapInfo(inImage)
                                                 );        
        
        const int imageWidth  = CGImageGetWidth(inImage);
        const int imageHeight = CGImageGetHeight(inImage);
        applyStackBlurToBuffer(m_PixelBuf, imageWidth, imageHeight, _blurRadius);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
        CGContextRelease(ctx);
        
        UIImage * finalImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CFRelease(m_DataRef);
        free(m_PixelBuf);
        
        blurLayer.image = finalImage;
        dispatch_async(dispatch_get_main_queue(), ^{
            blurLayer.alpha = _blurValue;
            [self addSubview:blurLayer];            
        });
    });
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _blurRadius = 25;
        _blurValue = 0;
        [self addBlurLayer];
    }
    return self;    
}

-(id)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        _blurRadius = 25;
        _blurValue = 0;
        [self addBlurLayer];
    }
    return self;
}

-(void)setImage:(UIImage *)image {
    [super setImage:image];
    [self addBlurLayer];
}

-(void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    [self addBlurLayer];
    blurLayer.contentMode = contentMode;
}

-(void)setBlurValue:(CGFloat)blurValue {
    _blurValue = blurValue;
    if (blurLayer) {
        blurValue = MAX(0, MIN (blurValue, 1.0));
        blurLayer.alpha = blurValue;
    }
}

-(void)setBlurRadius:(NSInteger)blurRadius {
    _blurRadius = blurRadius;
    [self addBlurLayer];
}

@end
