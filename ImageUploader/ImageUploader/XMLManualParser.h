//
//  XMLManualParser.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLManualParser : NSObject {

}

+(NSString *)getTagValue:(NSString *)tagName XMLContent:(NSString *)xmlContent;

@end
