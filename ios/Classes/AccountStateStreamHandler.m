#import "AccountStateStreamHandler.h"

#import <ChatSDK/ChatSDK.h>
#import <MessagingSDK/MessagingSDK.h>
#import <ChatProvidersSDK/ChatProvidersSDK.h>

@implementation AccountStateStreamHandler
{
    // Listeners
    NSMutableDictionary* listeners;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    [self startListening:arguments emitter:events];
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    [self cancelListening:arguments];
    return nil;
}

- (void) startListening:(id)listener emitter:(FlutterEventSink)emitter {
    // Prepare callback dictionary
    if (self->listeners == nil) self->listeners = [NSMutableDictionary new];
    
    // Get callback id
    NSString* currentListenerId =
        [[NSNumber numberWithUnsignedInteger:[((NSObject*) listener) hash]] stringValue];

    ZDKObservationToken *token = [ZDKChat.instance.providers.accountProvider observeAccount:^(ZDKChatAccount *account) {
        NSMutableDictionary* dict = [NSMutableDictionary new];
        
        [dict setValue:account.accountStatus == 1 ? @true : @false forKey:@"accountStatus"];
        
        NSMutableArray* departments = [NSMutableArray new];
        
        if (account.departments) for (ZDKDepartment* department in account.departments) {
            NSMutableDictionary* departmentMap = [NSMutableDictionary new];
            [departmentMap setValue:department.id forKey:@"id"];
            [departmentMap setValue:department.name forKey:@"name"];
            
            NSString* depStatus;
            switch (department.departmentStatus) {
                case ZDKDepartmentStatusAway:
                    depStatus = @"Away";
                    break;
                case ZDKDepartmentStatusOffline:
                    depStatus = @"Offline";
                    break;
                case ZDKDepartmentStatusOnline:
                    depStatus = @"Online";
                    break;
            }
            [departmentMap setValue:depStatus forKey:@"status"];
            [departments addObject: departmentMap];
        }
        
        [dict setValue:departments forKey:@"departments"];
        
        emitter(dict);
    }];

    // Run task
    [self->listeners setObject:token forKey:currentListenerId];
}
- (void) cancelListening:(id)listener {
    // Get callback id
    NSString* currentListenerId =
        [[NSNumber numberWithUnsignedInteger:[((NSObject*) listener) hash]] stringValue];
    
    ZDKObservationToken* token = [self->listeners objectForKey:currentListenerId];
    if (token) [token cancel];
    
    // Remove callback
    [self->listeners removeObjectForKey:currentListenerId];
}

@end
