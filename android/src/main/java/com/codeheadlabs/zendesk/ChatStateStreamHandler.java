package com.codeheadlabs.zendesk;

import io.flutter.plugin.common.EventChannel;
import zendesk.chat.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatStateStreamHandler implements EventChannel.StreamHandler {
    private ObservationScope scope;

    @Override
    public void onListen(Object arguments, final EventChannel.EventSink events) {
        final ChatProvider chatProvider = Chat.INSTANCE.providers().chatProvider();
        scope = new ObservationScope();
        chatProvider.observeChatState(scope, new Observer<ChatState>() {
            @Override
            public void update(ChatState chatState) {
                events.success(chatStateToMap(chatState));
            }
        });
    }

    @Override
    public void onCancel(Object arguments) {
        if (scope != null && !scope.isCancelled()) scope.cancel();
    }

    private static Map<String, Object> chatStateToMap(ChatState chatState) {
        final HashMap<String, Object> map = new HashMap<>();
        map.put("chatId", chatState.getChatId());
        map.put("chatComment", chatState.getChatComment());
        map.put("chatSessionStatus", chatState.getChatSessionStatus());
        map.put("chatRating", chatState.getChatRating() != null ? chatState.getChatRating().toString() : null);
        map.put("isChatting", chatState.isChatting());
        map.put("queuePosition", chatState.getQueuePosition());

        final List<HashMap<String, Object>> agents = new ArrayList<>();
        for (Agent agent : chatState.getAgents()) {
            final HashMap<String, Object> agentMap = new HashMap<>();
            agentMap.put("avatarPath", agent.getAvatarPath());
            agentMap.put("displayName", agent.getDisplayName());
            agentMap.put("nick", agent.getNick());
            agentMap.put("isTyping", agent.isTyping());
            agents.add(agentMap);
        }

        map.put("agents", agents);

        return map;
    }
}
