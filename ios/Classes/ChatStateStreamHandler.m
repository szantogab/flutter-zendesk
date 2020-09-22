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
        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setValue:state.chatId forKey:@"chatId"];
        [dict setValue:state.comment forKey:@"chatComment"];
        //@"chatSessionStatus": 0, // TODO use swift enum
        //@"chatRating": 0, // TODO use swift enum
        [dict setValue:[NSNumber numberWithBool: state.isChatting] forKey:@"isChatting"];
        [dict setValue:[NSNumber numberWithLong: state.queuePosition.queue] forKey:@"queuePosition"];
        [dict setValue:[NSNumber numberWithLong: state.agents.count] forKey:@"agentCount"];
        
        NSMutableArray* agents = [NSMutableArray new];
        
        if (state.agents) for (ZDKAgent* agent in state.agents) {
            NSMutableDictionary* agentMap = [NSMutableDictionary new];
            [agentMap setValue:agent.avatar.absoluteString forKey:@"avatarPath"];
            [agentMap setValue:agent.displayName forKey:@"displayName"];
            [agentMap setValue:agent.nick forKey:@"nick"];
            [agentMap setValue: [NSNumber numberWithBool: agent.isTyping] forKey:@"isTyping"];
            [agents addObject: agentMap];
        }
        
        [dict setValue:agents forKey:@"agents"];

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
