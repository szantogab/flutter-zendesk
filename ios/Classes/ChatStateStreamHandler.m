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
    NSLog(@"Start listening..");

    
    if (self->listeners == nil) self->listeners = [NSMutableDictionary new];
    
    NSLog(@"Listeners inited..");

    
    // Get callback id
    NSString* currentListenerId =
        [[NSNumber numberWithUnsignedInteger:[((NSObject*) listener) hash]] stringValue];
    
    NSLog(@"Listener ID calculated.");

    
    ZDKObservationToken* token = [ZDKChat.instance.providers.chatProvider observeChatState:^(ZDKChatState * _Nonnull state) {
        NSLog(@"Updating chat status..");
        
        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setValue:state.chatId forKey:@"chatId"];
        [dict setValue:state.comment forKey:@"chatComment"];
        //@"chatSessionStatus": 0, // TODO use swift enum
        //@"chatRating": 0, // TODO use swift enum
        [dict setValue:[NSNumber numberWithBool: state.isChatting] forKey:@"isChatting"];
        [dict setValue:[NSNumber numberWithLong: state.queuePosition.queue] forKey:@"queuePosition"];
        [dict setValue:[NSNumber numberWithLong: state.agents.count] forKey:@"agentCount"];
        [dict setValue:[NSMutableArray new] forKey:@"agents"];
        NSLog(@"Emitting new.....");
        
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
