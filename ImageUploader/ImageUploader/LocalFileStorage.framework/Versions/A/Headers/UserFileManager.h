//
//  FileManager.h
//  JoomlaDay
//
//  Created by Mac HDD on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserFileManager : NSObject {
    
}

- (NSData *)getContentForPath:(NSString *)fileName;
- (UIImage *)getImageForPath:(NSString *)fileName;
- (BOOL)setContentForPath:(NSString *)filePath FileContent:(NSData *)fileData;
- (BOOL)setImageForPath:(NSString *)filePath FileContent:(NSData *)fileData;
- (void)saveFilePathMapings;

@end
