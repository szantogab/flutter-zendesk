#import "ChatStateStreamHandler.h"

#import <ChatSDK/ChatSDK.h>
#import <MessagingSDK/MessagingSDK.h>
#import <ChatProvidersSDK/ChatProvidersSDK.h>

@implementation ChatStateStreamHandler
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
    
    ZDKObservationToken* token = [ZDKChat.instance.providers.chatProvider observeChatState:^(ZDKChatState * _Nonnull state) {
        emitter(@{
            @"chatId": state.chatId,
            @"chatComment": state.comment,
            //@"chatSessionStatus": 0, // TODO use swift enum
            //@"chatRating": 0, // TODO use swift enum
            @"isChatting": [NSNumber numberWithBool: state.isChatting],
            @"queuePosition": [NSNumber numberWithLong: state.queuePosition.queue],
            @"agentCount": [NSNumber numberWithLong: state.agents.count]
        });
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
