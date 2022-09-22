//
//  EverythingHelpers.m
//  Everything
//
//  Created by Jonathan Wight on 3/10/21.
//

#import <Foundation/Foundation.h>

#include <sys/syslimits.h>
#include <fcntl.h>

int fcntl_FGETPATH(int fd, char *path) {
    //char filePath[PATH_MAX];
    return fcntl(fd, F_GETPATH, path);
}
